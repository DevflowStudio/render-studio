import 'dart:ui';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:octo_image/octo_image.dart';
import 'package:universal_io/io.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../rehmat.dart';

class UnsplashImagePicker extends StatefulWidget {

  UnsplashImagePicker({Key? key}) : super(key: key);

  static Future<File?> getImage(BuildContext context, {
    String? query,
    bool crop = false,
    CropAspectRatio? cropRatio,
    bool forceCrop = true,
  }) async {
    final File? file = await AppRouter.push(
      context,
      page: UnsplashImagePicker()
    );
    if (file == null) return null;
    if (crop) {
      File? cropped = await FilePicker.crop(context, file: file, ratio: cropRatio, forceCrop: forceCrop);
      if (cropped == null) return null;
      return cropped;
    } else return file;
  }

  @override
  State<UnsplashImagePicker> createState() => _UnsplashImagePickerState();
}

class _UnsplashImagePickerState extends State<UnsplashImagePicker> {

  TextEditingController searchCtrl = TextEditingController();

  UnsplashPhoto? selected;

  String? query;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            cacheExtent: MediaQuery.of(context).size.height * 3,
            slivers: [
              RenderAppBar(
                title: Text('Unsplash'),
                isExpandable: false,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3
                  ),
                  child: RenderSearchBar(
                    controller: searchCtrl,
                    placeholder: 'Search',
                    onSubmitted: (value) {
                      if (value.trim().isEmpty) setState(() {
                        query = null;
                      });
                      else setState(() {
                        query = value;
                      });
                    },
                  ),
                ),
              ),
              UnsplashResultBuilder(
                query: query,
                downloadOnSelect: false,
                onSelect: (file, photo) {
                  selected = photo;
                  setState(() { });
                },
              ),
            ],
          ),
          if (selected != null) Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: Constants.of(context).bottomPadding,
                left: 12,
                right: 12
              ),
              child: UnsplashPhotoInfo(
                photo: selected!,
                onDownload: (file) {
                  if (file != null) Navigator.of(context).pop(file);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

}

class UnsplashPhotoInfo extends StatefulWidget {

  const UnsplashPhotoInfo({
    Key? key,
    required this.photo,
    this.onDownload
  }) : super(key: key);

  final UnsplashPhoto photo;
  final Function(File? file)? onDownload;

  @override
  State<UnsplashPhotoInfo> createState() => _UnsplashPhotoInfoState();
}

class _UnsplashPhotoInfoState extends State<UnsplashPhotoInfo> {

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        decoration: BoxDecoration(
          color: Palette.blurBackground(context),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            right: 12,
          ),
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: SizedBox(),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Alerts.snackbar(
                          context,
                          text: 'Visit @${widget.photo.user.username}\'s portfolio?',
                          action: SnackBarAction(
                            label: 'Visit',
                            onPressed: () {
                              launchUrl(Uri.parse(widget.photo.user.portfolioURL));
                            },
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 12,
                          top: 12,
                          bottom: 12
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: OctoImage(
                                  image: NetworkImage(
                                    widget.photo.user.profileImage
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 6,),
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.photo.user.name,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Photo by: @${widget.photo.user.username}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (isLoading) return;
                        setState(() {
                          isLoading = true;
                        });
                        if (widget.onDownload != null) {
                          try {
                            File photo = await widget.photo.download(context);
                            widget.onDownload!(photo);
                            setState(() {
                              isLoading = false;
                            });
                          } catch (e) {
                            Alerts.dialog(
                              context,
                              title: 'Failed to download',
                              content: 'Could not download the photo. Please try again later.',
                            );
                          }
                        }
                      },
                      child: isLoading ? SizedBox(
                        width: 13,
                        height: 13,
                        child: Spinner(
                          strokeWidth: 1.5,
                          valueColor: Palette.of(context).onPrimary,
                        )
                      ) : Text(
                        'Select',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Palette.of(context).onPrimary
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 22,
                        )
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class UnsplashResultBuilder extends StatefulWidget {

  const UnsplashResultBuilder({
    super.key,
    this.query,
    required this.onSelect,
    this.downloadOnSelect = true
  });

  final String? query;
  final Function(File? file, UnsplashPhoto photo) onSelect;
  final bool downloadOnSelect;

  @override
  State<UnsplashResultBuilder> createState() => _UnsplashResultBuilderState();
}

class _UnsplashResultBuilderState extends State<UnsplashResultBuilder> {

  late final UnsplashAPI api;

  @override
  void initState() {
    super.initState();
    api = UnsplashAPI(query: widget.query);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.query != api.searchTerm) api.search(widget.query);
    return PagedSliverBuilder<int, UnsplashPhoto>(
      pagingController: api.controller,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (context, photo, index) {
          return SizedBox(
            height: ((MediaQuery.of(context).size.width / 2) - 4.5) / (photo.size.width / photo.size.height),
            width: (MediaQuery.of(context).size.width / 2) - 4.5,
            child: UnsplashPhotoBuilder(
              photo: photo,
              onSelect: widget.onSelect,
              downloadOnSelect: widget.downloadOnSelect
            ),
          );
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
            mainAxisAlignment: MainAxisAlignment.center,
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
            mainAxisAlignment: MainAxisAlignment.center,
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
                'Try searching for something',
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
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
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

class UnsplashPhotoBuilder extends StatefulWidget {

  UnsplashPhotoBuilder({
    Key? key,
    required this.photo,
    required this.onSelect,
    this.downloadOnSelect = true
  }) : super(key: key);

  final UnsplashPhoto photo;
  final Function(File? file, UnsplashPhoto photo) onSelect;
  final bool downloadOnSelect;

  @override
  State<UnsplashPhotoBuilder> createState() => __UnsplashPhotoBuilderState();
}

class __UnsplashPhotoBuilderState extends State<UnsplashPhotoBuilder> {

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
    return TouchRippleEffect(
      rippleColor: Palette.of(context).background,
      rippleDuration: kAnimationDuration,
      onTap: () async {
        if (widget.downloadOnSelect) {
          try {
            File downloaded = await photo.download(context);
            widget.onSelect(downloaded, photo);
          } catch (e) {
            Alerts.dialog(
              context,
              title: 'Failed to download',
              content: 'Could not download the photo. Please try again later.'
            );
          }
        }
        else widget.onSelect(null, photo);
      },
      child: AnimatedSwitcher(
        duration: Constants.animationDuration,
        child: photo.isLoading ? Stack(
          children: [
            if (photo.blurHash != null) BlurHash(
              hash: photo.blurHash!,
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
                      color: Palette.blurBackground(context)
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
          placeholderBuilder: photo.blurHash != null ? (context) => BlurHash(
            hash: photo.blurHash!,
          ) : null,
          errorBuilder: (context, error, stackTrace) => Stack(
            children: [
              if (photo.blurHash != null) BlurHash(
                hash: photo.blurHash!,
              ),
              Align(
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Palette.blurBackground(context)
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
    );
  }
}