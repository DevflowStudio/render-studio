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

UnsplashSearchAPI _searchAPI = UnsplashSearchAPI();
UnsplashTopicAPI _topicAPI = UnsplashTopicAPI();

class UnsplashImagePicker extends StatefulWidget {

  UnsplashImagePicker({
    Key? key,
    this.searchSuggestions = const []
  }) : super(key: key);

  final List<String> searchSuggestions;

  static Future<File?> getImage(BuildContext context, {
    String? query,
    bool crop = false,
    CropAspectRatio? cropRatio,
    bool forceCrop = true,
    List<String> searchSuggestions = const []
  }) async {
    final File? file = await AppRouter.push(
      context,
      page: UnsplashImagePicker(
        searchSuggestions: searchSuggestions,
      )
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

  UnsplashTopic? topic;

  late List<String> searchSuggestions;

  @override
  void initState() {
    searchSuggestions = widget.searchSuggestions;
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

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
                isExpandable: true,
              ),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: kAnimationDuration,
                  child: topic == null ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12
                        ),
                        child: RenderSearchBar(
                          controller: searchCtrl,
                          placeholder: 'Search photos',
                          onSubmitted: (value) {
                            if (value.trim().isEmpty) setState(() {
                              query = null;
                              topic = null;
                            });
                            else setState(() {
                              query = value;
                              topic = null;
                              _searchAPI = UnsplashSearchAPI(query: value);
                            });
                          },
                        ),
                      ),
                      if (searchSuggestions.isNotEmpty) Padding(
                        padding: const EdgeInsets.only(
                          top: 6
                        ),
                        child: SizedBox(
                          height: 30,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: searchSuggestions.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  TapFeedback.light();
                                  setState(() {
                                    searchCtrl.text = searchSuggestions[index];
                                    query = searchSuggestions[index];
                                    topic = null;
                                    _searchAPI = UnsplashSearchAPI(query: searchSuggestions[index]);
                                  });
                                },
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Palette.of(context).surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Palette.of(context).outline,
                                      width: 1
                                    )
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12
                                  ),
                                  child: Center(
                                    child: Text(
                                      searchSuggestions[index],
                                    ),
                                  )
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => SizedBox(width: 3),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12
                            ),
                          ),
                        ),
                      )
                    ],
                  ) : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12
                    ),
                    child: Row(
                      children: [
                        Chip(
                          avatar: ClipOval(
                            child: OctoImage(
                              image: CachedNetworkImageProvider(topic!.coverPhotoURL),
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                              placeholderBuilder: topic!.blurHash != null ? (context) => BlurHash(
                                hash: topic!.blurHash!,
                              ) : null,
                            ),
                          ),
                          labelPadding: EdgeInsets.only(
                            left: 9,
                            right: 6
                          ),
                          label: Text(
                            topic!.title,
                          ),
                          deleteIcon: Icon(
                            RenderIcons.close,
                            size: 18,
                          ),
                          onDeleted: () {
                            setState(() {
                              topic = null;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SliverAnimatedSwitcher(
                duration: kAnimationDuration,
                child: (query != null || topic != null) ? UnsplashResultBuilder<UnsplashPhoto>(
                  pagingController: _searchAPI.controller,
                  itemBuilder: (_, photo, index) => SizedBox(
                    height: (MediaQuery.of(context).size.width / 2) / (photo.size.width / photo.size.height),
                    width: MediaQuery.of(context).size.width / 2,
                    child: UnsplashPhotoBuilder(
                      photo: photo,
                      onDownload: (file, photo) {
                        Navigator.of(context).pop(file);
                      },
                      onSelect: () => setState(() {
                        if (selected == photo) selected = null;
                        else selected = photo;
                      }),
                      isSelected: selected == photo,
                    ),
                  ),
                ) : UnsplashResultBuilder<UnsplashTopic>(
                  pagingController: _topicAPI.controller,
                  itemBuilder: (context, topic, index) {
                    return UnsplashTopicBuilder(
                      topic: topic,
                      onSelect: () {
                        setState(() {
                          this.topic = topic;
                          _searchAPI = UnsplashSearchAPI(topic: topic);
                        });
                      },
                    );
                  },
                )
              )
            ],
          ),
        ],
      ),
    );
  }

}

class UnsplashResultBuilder<T> extends StatelessWidget {

  const UnsplashResultBuilder({
    super.key,
    required this.pagingController,
    required this.itemBuilder,
    this.padding = const EdgeInsets.only(
      top: 12
    ),
    this.verticalSpacing = 2,
    this.horizontalSpacing = 2
  });

  final PagingController<int, T> pagingController;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final EdgeInsets padding;
  final double verticalSpacing;
  final double horizontalSpacing;

  @override
  Widget build(BuildContext context) {
    return PagedLayoutBuilder<int, T>(
      pagingController: pagingController,
      layoutProtocol: PagedLayoutProtocol.sliver,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: itemBuilder,
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
        context,
        itemBuilder: itemBuilder,
        itemCount: itemCount,
      ),
      loadingListingBuilder: (
        context,
        itemBuilder,
        itemCount,
        progressIndicatorBuilder,
      ) => _gridBuilder(
        context,
        itemBuilder: itemBuilder,
        itemCount: itemCount,
      ),
      errorListingBuilder: (
        context,
        itemBuilder,
        itemCount,
        errorIndicatorBuilder,
      ) => _gridBuilder(
        context,
        itemBuilder: itemBuilder,
        itemCount: itemCount,
      ),
    );
  }

  Widget _gridBuilder(BuildContext context, {
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    Widget Function(BuildContext)? secondaryBuilder
  }) => SliverPadding(
    padding: padding,
    sliver: MultiSliver(
      children: [
        SliverMasonryGrid(
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: itemCount,
          ),
          crossAxisSpacing: horizontalSpacing,
          mainAxisSpacing: verticalSpacing,
          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
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
    required this.onDownload,
    this.isSelected = false
  }) : super(key: key);

  final UnsplashPhoto photo;
  final Function(File file, UnsplashPhoto photo) onDownload;
  final void Function() onSelect;
  final bool isSelected;

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
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        File? downloaded;
        await Spinner.fullscreen(
          context,
          task: () async {
            try {
              downloaded = await photo.download(context);
            } catch (e) {
              Alerts.dialog(
                context,
                title: 'Download Failed',
                content: 'We are experiencing issues downloading the image. Please try again later.'
              );
            }
          }
        );
        print('Downloadededed file: $downloaded path: ${downloaded?.path}');
        if (downloaded != null) {
          widget.onDownload(downloaded!, photo);
        }
      },
      child: AnimatedSwitcher(
        duration: Constants.animationDuration,
        child: Stack(
          children: [
            buildImage(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black
                  ],
                  stops: [
                    0.5,
                    1
                  ]
                )
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6
                ),
                child: Row(
                  children: [
                    ClipOval(
                      child: OctoImage(
                        image: CachedNetworkImageProvider(photo.user.profileImage),
                        width: 15,
                        height: 15,
                      ),
                    ),
                    SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        photo.user.name,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildImage() => OctoImage(
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
  );

}

class UnsplashTopicBuilder extends StatefulWidget {

  UnsplashTopicBuilder({
    Key? key,
    required this.topic,
    required this.onSelect,
  }) : super(key: key);

  final UnsplashTopic topic;
  final void Function() onSelect;

  @override
  State<UnsplashTopicBuilder> createState() => _UnsplashTopicBuilderState();
}

class _UnsplashTopicBuilderState extends State<UnsplashTopicBuilder> {

  late UnsplashTopic topic;

  void onChanged() {
    setState(() {});
  }

  @override
  void initState() {
    topic = widget.topic;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width / 2;
    double _height = _width / (topic.size.width / topic.size.height);
    return GestureDetector(
      onTap: widget.onSelect,
      child: AnimatedSwitcher(
        duration: Constants.animationDuration,
        child: SizedBox(
          width: _width,
          height: _height,
          child: OctoImage(
            image: CachedNetworkImageProvider(topic.coverPhotoURL),
            imageBuilder: (context, child) {
              return Stack(
                children: [
                  child,
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black
                        ],
                        stops: [
                          0.5,
                          1
                        ]
                      )
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Text(
                      topic.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white
                      ),
                    )
                  )
                ],
              );
            },
            placeholderBuilder: topic.blurHash != null ? (context) => BlurHash(
              hash: topic.blurHash!,
            ) : null,
            errorBuilder: (context, error, stackTrace) => Stack(
              children: [
                if (topic.blurHash != null) BlurHash(
                  hash: topic.blurHash!,
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
      ),
    );
  }
}