import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:skeletons/skeletons.dart';
import 'package:universal_io/io.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../rehmat.dart';

Future<List<UnsplashPhoto>?>? _unsplashStockImages;
Future<List<IconFinderIcon>?>? _iconFinderStockIcons;

/// Widget used when pressing "Add Widget" button in background editor in `create.dart` screen
/// Showcases all the widgets and assets (from APIs) available
class WidgetCatalog extends StatefulWidget {

  const WidgetCatalog({
    super.key,
    required this.page
  });

  final CreatorPage page;

  @override
  State<WidgetCatalog> createState() => _WidgetCatalogState();
}

class _WidgetCatalogState extends State<WidgetCatalog> with SingleTickerProviderStateMixin {

  String? query;

  late TabController tabCtrl;

  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabCtrl = TabController(
      length: 2,
      vsync: this
    );
    _unsplashStockImages ??= UnsplashAPI.query();
    _iconFinderStockIcons ??= IconFinder.query([
      'social',
      'ai',
      'arrows',
      'avatars',
      'business',
      'people'
    ].getRandom(), limit: 20);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> widgets = {
      'qr_code': {
        'title': 'QR Code',
        'icon': Icon(
          RenderIcons.qr,
          size: 30,
          color: Palette.of(context).onSurfaceVariant,
        ),
      },
      'progress': {
        'title': 'Progress',
        'icon': Icon(
          RenderIcons.progress,
          size: 30,
          color: Palette.of(context).onSurfaceVariant,
        ),
      },
      'pie-chart': {
        'title': 'Pie Chart',
        'icon': Icon(
          RenderIcons.pieChart,
          size: 30,
          color: Palette.of(context).onSurfaceVariant,
        ),
      },
      'box': {
        'title': 'Box',
        'icon': Icon(
          RenderIcons.design_asset,
          size: 30,
          color: Palette.of(context).onSurfaceVariant,
        ),
      },
      'blob': {
        'title': 'Blob',
        'icon': Blob.random(
          size: 30,
          styles: BlobStyles(
            color: Palette.of(context).onSurfaceVariant,
          ),
        ),
      },
    };
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: CustomScrollView(
        cacheExtent: MediaQuery.of(context).size.height * 3,
        slivers: [
          SliverPinnedHeader(
            // padding: const EdgeInsets.only(
            //   right: 12,
            //   bottom: 12
            // ),
            child: Container(
              color: Palette.of(context).background.withOpacity(0.2),
              child: ClipRRect(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: AppBar().preferredSize.height,
                    bottom: 6,
                    right: 12
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(RenderIcons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: SearchBar(
                            controller: searchCtrl,
                            placeholder: 'Search Images and Design Assets',
                            onSuffixTap: () => setState(() {
                              searchCtrl.clear();
                              query = null;
                            }),
                            onSubmitted: (value) {
                              if (value.isEmpty || value.trim().isEmpty) {
                                setState(() => query = null);
                              } else {
                                setState(() => query = value);
                              }
                            },
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 6
            ),
          ),
          if (query != null) ... [
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (Platform.isIOS) CupertinoSlidingSegmentedControl<int>(
                    groupValue: tabCtrl.index,
                    children: {
                      0: Text('Unsplash'),
                      1: Text('IconFinder'),
                    },
                    onValueChanged: (value) => setState(() {
                      tabCtrl.animateTo(value ?? 0);
                    }),
                  ) else Expanded(
                    child: TabBar(
                      controller: tabCtrl,
                      enableFeedback: true,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: Constants.getThemedBlackAndWhite(context),
                      labelColor: Constants.getThemedBlackAndWhite(context),
                      unselectedLabelColor: Constants.getThemedBlackAndWhite(context).withOpacity(0.5),
                      labelStyle: Theme.of(context).textTheme.subtitle2,
                      tabs: [
                        Tab(
                          text: 'Unsplash',
                        ),
                        Tab(
                          text: 'IconFinder',
                        ),
                      ],
                      onTap: (value) => setState(() {
                        tabCtrl.animateTo(value);
                      }),
                    ),
                  )
                ],
              ),
            ),
            SliverVisibility(
              maintainState: true,
              maintainAnimation: true,
              visible: tabCtrl.index == 0,
              sliver: UnsplashResultBuilder(
                query: query!,
                onSelect: (file) {
                  if (file == null) return;
                  Navigator.of(context).pop();
                  ImageWidget.create(context, page: widget.page, file: file);
                },
              )
            ),
            SliverVisibility(
              maintainState: true,
              maintainAnimation: true,
              visible: tabCtrl.index == 1,
              sliver: IconFinderResults(
                query: query!,
                onSelect: (file) {
                  if (file == null) return;
                  Navigator.of(context).pop();
                  CreatorDesignAsset.create(context, page: widget.page, file: file);
                },
              )
            ),
          ]
          else ... [
            label('Text'),
            verticalListBuilder(
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  TapFeedback.light();
                  _TextStyles.values[index].create(context, page: widget.page);
                  Navigator.of(context).pop();
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                  color: Palette.of(context).surfaceVariant,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Add a ${_TextStyles.values[index].name} text',
                      style: _TextStyles.values[index].style,
                    ),
                  ),
                ),
              ),
              itemCount: _TextStyles.values.length,
            ),
            spacing,
            label('Widgets'),
            horizontalListBuilder(
              itemBuilder: (context, index) => GestureDetector(
                onTap: () async {
                  TapFeedback.light();
                  await CreatorWidget.create(context, id: widgets.keys.elementAt(index), page: widget.page);
                  Navigator.of(context).pop();
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                  color: Palette.of(context).surfaceVariant,
                  child: Center(
                    child: Column(
                      children: [
                        Spacer(
                          flex: 2,
                        ),
                        widgets.values.elementAt(index)['icon'],
                        Spacer(
                          flex: 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 6,
                            left: 6,
                            right: 6
                          ),
                          child: AutoSizeText(
                            widgets.values.elementAt(index)['title'],
                            style: TextStyle(
                              color: Palette.of(context).onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            minFontSize: 10,
                            maxFontSize: 13,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              itemCount: widgets.length,
            ),
            spacing,
            label('Unsplash'),
            FutureBuilder<List<UnsplashPhoto>?>(
              future: _unsplashStockImages,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.data == null) return errorBuilder('We are facing issues loading images from Unsplash');
                else if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) return horizontalListBuilder(
                  itemBuilder: (context, index) {
                    UnsplashPhoto photo = snapshot.data![index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: OctoImage.fromSet(
                        image: CachedNetworkImageProvider(photo.url),
                        octoSet: OctoSet.blurHash(
                          photo.blurHash
                        ),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                  itemCount: snapshot.data!.length
                );
                else return loadingList();
              },
            ),
            spacing,
            label('Shapes'),
            horizontalListBuilder(
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  TapFeedback.light();
                  ShapeWidget.create(context, page: widget.page, shape: RenderShapeAbstract.names[index]);
                  Navigator.of(context).pop();
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                  color: Palette.of(context).surfaceVariant,
                  child: Center(
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: CustomPaint(
                        painter: CreativeShape(
                          name: RenderShapeAbstract.names[index],
                          color: Palette.of(context).onSurfaceVariant
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              itemCount: RenderShapeAbstract.names.length
            ),
            spacing,
            label('Design Assets'),
            FutureBuilder<List<IconFinderIcon>?>(
              future: _iconFinderStockIcons,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.data == null) return errorBuilder('We are facing issues loading assets from IconFinder');
                else if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) return horizontalListBuilder(
                  itemBuilder: (context, index) {
                    IconFinderIcon icon = snapshot.data![index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: OctoImage(
                            image: NetworkImage(icon.previewURLs.reversed.toList()[2]),
                            placeholderBuilder: (context) => Center(
                              child: Spinner()
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: snapshot.data!.length
                );
                else return loadingList();
              },
            )
          ],
        ],
      ),
    );
  }

  Widget get spacing => SliverToBoxAdapter(
    child: SizedBox(height: 6),
  );

  Widget label(String text) => SliverPadding(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 6
    ),
    sliver: SliverToBoxAdapter(
      child: Text(
        text,
        style: Theme.of(context).textTheme.subtitle1?.copyWith(
          color: Palette.of(context).onSurfaceVariant
        ),
      ),
    ),
  );

  Widget verticalListBuilder({
    required Widget Function(BuildContext context, int index) itemBuilder,
    required int itemCount
  }) => SliverToBoxAdapter(
    child: ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 12),
      separatorBuilder: (context, index) => SizedBox(height: 6),
      cacheExtent: MediaQuery.of(context).size.width * 3,
      shrinkWrap: true,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      physics: NeverScrollableScrollPhysics(),
    ),
  );

  Widget horizontalListBuilder({
    required Widget Function(BuildContext context, int index) itemBuilder,
    required int itemCount
  }) => SliverToBoxAdapter(
    child: SizedBox(
      height: 80,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => SizedBox(width: 6),
        cacheExtent: MediaQuery.of(context).size.width * 3,
        itemBuilder: (context, index) => SizedBox(
          height: 80,
          width: 80,
          child: itemBuilder(context, index)
        ),
        itemCount: itemCount
      ),
    ),
  );

  Widget loadingList() => horizontalListBuilder(
    itemBuilder: (context, index) => SkeletonAvatar(
      style: SkeletonAvatarStyle(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    itemCount: 10
  );

  Widget errorBuilder(String error) => SliverPadding(
    padding: const EdgeInsets.symmetric(
      horizontal: 12
    ),
    sliver: SliverToBoxAdapter(
      child: Row(
        children: [
          Icon(
            RenderIcons.error,
            color: Palette.of(context).error,
          ),
          SizedBox(width: 9),
          Flexible(
            child: Text(
              error,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Palette.of(context).error,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    ),
  );

}

enum _TextStyles {
  title,
  subtitle,
  body,
}

extension _TextStyleExtension on _TextStyles {

  String get name {
    switch (this) {
      case _TextStyles.title:
        return 'Title';
      case _TextStyles.subtitle:
        return 'Subtitle';
      case _TextStyles.body:
        return 'Body';
    }
  }

  String get text {
    switch (this) {
      case _TextStyles.title:
        return 'Title';
      case _TextStyles.subtitle:
        return 'Subtitle';
      case _TextStyles.body:
        return 'Add the body of your post here';
    }
  }

  void create(BuildContext context, {
    required CreatorPage page
  }) {
    CreatorText widget = CreatorText(page: page);
    TextStyle? style = actualStyle(context)?.copyWith(
      color: page.palette.onBackground,
      height: 0.77
    );
    if (style != null) widget.primaryStyle = CreativeTextStyle.fromTextStyle(style, widget: widget);
    widget.text = text;
    widget.updateResizeHandlers();
    final span = TextSpan(
      style: style,
      text: text,
    );
    final words = span.toPlainText().split(RegExp('\\s+'));
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: style,
      ),
      textAlign: TextAlign.left,
      maxLines: words.length,
      textDirection: TextDirection.ltr
    ) ..layout(minWidth: 0, maxWidth: page.project.contentSize.width - 20);
    Size size = textPainter.size;
    widget.size = size;
    page.widgets.add(widget);
  }

  TextStyle get style {
    switch (this) {
      case _TextStyles.title:
        return TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700
        );
      case _TextStyles.subtitle:
        return TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600
        );
      case _TextStyles.body:
        return TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400
        );
      default:
        return TextStyle();
    }
  }

  TextStyle? actualStyle(BuildContext context) {
    switch (this) {
      case _TextStyles.title:
        return Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold
        );
      case _TextStyles.subtitle:
        return Theme.of(context).textTheme.headlineSmall;
      case _TextStyles.body:
        return Theme.of(context).textTheme.bodyLarge;
    }
  }

}