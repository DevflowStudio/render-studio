import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:octo_image/octo_image.dart';
import 'package:universal_io/io.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../../rehmat.dart';

class UnsplashImagePicker extends StatefulWidget {

  UnsplashImagePicker({Key? key}) : super(key: key);

  static Future<File?> getImage(BuildContext context, {
    String? query,
    bool crop = false,
    CropAspectRatio? cropRatio,
  }) async {
    final File? file = await AppRouter.push(
      context,
      page: UnsplashImagePicker()
    );
    if (file == null) return null;
    if (crop) {
      File? cropped = await FilePicker.crop(context, file: file, ratio: cropRatio);
      if (cropped == null) return null;
      return cropped;
    } else return file;
  }

  @override
  State<UnsplashImagePicker> createState() => _UnsplashImagePickerState();
}

class _UnsplashImagePickerState extends State<UnsplashImagePicker> {

  UnsplashAPI api = UnsplashAPI();

  TextEditingController searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          RenderAppBar(
            title: Text('Unsplash'),
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextFormField(
                controller: searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(RenderIcons.search),
                  suffixIcon: IconButton(
                    onPressed: () => searchCtrl.clear(),
                    icon: Icon(RenderIcons.clear)
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide.none
                  ),
                ),
                onFieldSubmitted: (value) {
                  api.search(value);
                },
              ),
            ),
          ),
          PagedSliverBuilder<int, UnsplashPhoto>(
            pagingController: api.controller,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, photo, index) {
                return _UnsplashPhotoBuilder(photo: photo);
              },
              firstPageErrorIndicatorBuilder: (context) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 24
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        RenderIcons.warning,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 9),
                    Text(
                      'There was an error',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  ],
                ),
              ),
              firstPageProgressIndicatorBuilder: (context) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  children: [
                    Center(
                      child: SizedBox.square(
                        dimension: 20,
                        child: Spinner(
                          adaptive: true,
                        ),
                      )
                    ),
                  ],
                ),
              ),
              newPageProgressIndicatorBuilder: (context) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  children: [
                    Center(
                      child: SizedBox.square(
                        dimension: 20,
                        child: Spinner(
                          adaptive: true,
                        ),
                      )
                    ),
                  ],
                ),
              ),
              newPageErrorIndicatorBuilder: (context) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 24
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        RenderIcons.warning,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 9),
                    Text(
                      'There was an error',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  ],
                ),
              ),
              noItemsFoundIndicatorBuilder: (context) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 24
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'That\'s all we have',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  ],
                ),
              )
            ),
            completedListingBuilder: (
              context,
              itemBuilder,
              itemCount,
              noMoreItemsIndicatorBuilder,
            ) => _gridBuilder(
              itemBuilder: itemBuilder,
              itemCount: itemCount,
            ),
            loadingListingBuilder: (
              context,
              itemBuilder,
              itemCount,
              progressIndicatorBuilder,
            ) => _gridBuilder(
              itemBuilder: itemBuilder,
              itemCount: itemCount,
            ),
            errorListingBuilder: (
              context,
              itemBuilder,
              itemCount,
              errorIndicatorBuilder,
            ) => _gridBuilder(
              itemBuilder: itemBuilder,
              itemCount: itemCount,
            ),
          )
        ],
      ),
    );
  }

  Widget _gridBuilder({
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    Widget Function(BuildContext)? secondaryBuilder
  }) => SliverPadding(
    padding: const EdgeInsets.symmetric(
      vertical: 12
    ),
    sliver: MultiSliver(
      children: [
        SliverPadding(
          padding: const EdgeInsets.all(3.0),
          sliver: SliverMasonryGrid(
            delegate: SliverChildBuilderDelegate(
              itemBuilder,
              childCount: itemCount,
            ),
            crossAxisSpacing: 0,
            mainAxisSpacing: 0,
            gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
          ),
        ),
        if (secondaryBuilder != null) SliverToBoxAdapter(
          child: secondaryBuilder(context)
        )
      ],
    ),
  );

}

class _UnsplashPhotoBuilder extends StatefulWidget {

  _UnsplashPhotoBuilder({
    Key? key,
    required this.photo,
  }) : super(key: key);

  final UnsplashPhoto photo;

  @override
  State<_UnsplashPhotoBuilder> createState() => __UnsplashPhotoBuilderState();
}

class __UnsplashPhotoBuilderState extends State<_UnsplashPhotoBuilder> {

  late UnsplashPhoto photo;

  void onChanged() {
    setState(() {});
  }

  @override
  void initState() {
    photo = widget.photo;
    super.initState();
    photo.addListener(onChanged);
  }

  @override
  void dispose() {
    photo.removeListener(onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: (MediaQuery.of(context).size.width/2 - (6 + 6/3)), // adjusted for padding
          height: (MediaQuery.of(context).size.width/2 - (6 + 6/3)) * 1/photo.ratio,
          child: GestureDetector(
            onTap: () async {
              photo.download(
                context,
                onDownloadComplete: (file) {
                  if (file != null && mounted) Navigator.of(context).pop(file);
                },
              );
            },
            child: AnimatedSwitcher(
              duration: Constants.animationDuration,
              child: photo.isLoading ? Stack(
                children: [
                  BlurHash(
                    hash: photo.blurHash,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Palette.of(context).background.withOpacity(0.5)
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Spinner(
                                adaptive: false,
                                valueColor: Palette.of(context).onBackground,
                                strokeWidth: 2,
                                value: photo.progress,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ) : OctoImage(
                image: CachedNetworkImageProvider(photo.url),
                placeholderBuilder: (context) => BlurHash(
                  hash: photo.blurHash,
                ),
                errorBuilder: (context, error, stackTrace) => Stack(
                  children: [
                    BlurHash(
                      hash: photo.blurHash,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Palette.of(context).background.withOpacity(0.5)
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Icon(RenderIcons.warning),
                                  SizedBox(width: 6,),
                                  Text(
                                    'Unable to load image',
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}