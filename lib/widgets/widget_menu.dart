import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:octo_image/octo_image.dart';
import 'package:render_studio/creator/helpers/editor_manager.dart';
import 'package:skeletons/skeletons.dart';
import 'package:sprung/sprung.dart';
import 'package:universal_io/io.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../rehmat.dart';

Future<List<UnsplashPhoto>?>? _unsplashStockImages;
Future<List<IconFinderIcon>?>? _iconFinderStockIcons;

/// Widget used when pressing "Add Widget" button in background editor in `create.dart` screen
/// Showcases all the widgets and assets (from APIs) available
class WidgetMenu extends StatefulWidget {

  const WidgetMenu({
    super.key,
    required this.page
  });

  final CreatorPage page;

  @override
  State<WidgetMenu> createState() => _WidgetMenuState();
}

class _WidgetMenuState extends State<WidgetMenu> with SingleTickerProviderStateMixin {

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
        'onTap': () async {
          await QRWidget.create(context, page: widget.page);
          Navigator.of(context).pop();
        }
      },
      'progress': {
        'title': 'Progress',
        'icon': Icon(
          RenderIcons.progress,
          size: 30,
          color: Palette.of(context).onSurfaceVariant,
        ),
        'onTap': () async {
          await CreativeProgressWidget.create(context, page: widget.page);
          Navigator.of(context).pop();
        }
      },
      'pie-chart': {
        'title': 'Pie Chart',
        'icon': Icon(
          RenderIcons.pieChart,
          size: 30,
          color: Palette.of(context).onSurfaceVariant,
        ),
        'onTap': () async {
          await CreativePieChart.create(context, page: widget.page);
          Navigator.of(context).pop();
        }
      },
      // 'box': {
      //   'title': 'Box',
      //   'icon': Icon(
      //     RenderIcons.design_asset,
      //     size: 30,
      //     color: Palette.of(context).onSurfaceVariant,
      //   ),
      //   'onTap': () async {
      //     await CreatorBoxWidget.create(context, page: widget.page);
      //     Navigator.of(context).pop();
      //   }
      // },
      'blob': {
        'title': 'Blob',
        'icon': Blob.random(
          size: 30,
          styles: BlobStyles(
            color: Palette.of(context).onSurfaceVariant,
          ),
        ),
        'onTap': () async {
          await CreativeBlob.create(context, page: widget.page);
          Navigator.of(context).pop();
        }
      },
      'image': {
        'title': 'Upload Image',
        'icon': Icon(RenderIcons.upload),
        'onTap': () async {
          File? file = await FilePicker.pick(context: context, type: FileType.image, crop: true,);
          if (file == null) return;
          await ImageWidget.create(context, page: widget.page, file: file);
          Navigator.of(context).pop();
        }
      },
      'svg': {
        'title': 'Upload SVG',
        'icon': Icon(RenderIcons.upload),
        'onTap': () async {
          File? file = await FilePicker.pick(context: context, type: FileType.svg, crop: false);
          if (file == null) return;
          await CreatorDesignAsset.create(context, page: widget.page, file: file);
          Navigator.of(context).pop();
        }
      },
    };
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: CustomScrollView(
        cacheExtent: MediaQuery.of(context).size.height * 3,
        slivers: [
          SliverPinnedHeader(
            child: Container(
              color: Palette.of(context).background,
              child: ClipRRect(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: AppBar().preferredSize.height,
                    bottom: 6,
                    right: 12
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(RenderIcons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: RenderSearchBar(
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
                      labelStyle: Theme.of(context).textTheme.titleSmall,
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
                onSelect: (file, photo) {
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
                  await widgets.values.elementAt(index)['onTap']();
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
                              child: Spinner(
                                strokeWidth: 2,
                              )
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
            ),
            spacing,
            label('Unsplash'),
            SliverPadding(
              padding: const EdgeInsets.only(
                left: 3,
                right: 3
              ),
              sliver: FutureBuilder<List<UnsplashPhoto>?>(
                future: _unsplashStockImages,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done || snapshot.data == null) return SliverToBoxAdapter(
                    child: Center(
                      child: Spinner()
                    ),
                  );
                  return SliverMasonryGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        UnsplashPhoto photo = snapshot.data![index];
                        return SizedBox(
                          height: ((MediaQuery.of(context).size.width / 2) - 4.5) / (photo.size.width / photo.size.height),
                          width: (MediaQuery.of(context).size.width / 2) - 4.5,
                          child: UnsplashPhotoBuilder(
                            photo: photo,
                            onSelect: (file, photo) {
                              if (file == null) return;
                              ImageWidget.create(context, page: widget.page, file: file);
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      },
                      childCount: snapshot.data!.length
                    ),
                    gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  );
                }
              ),
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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
    Size size = calculateSizeForTextStyle(text, style: style, page: page);
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
        return Theme.of(context).textTheme.displayLarge;
      case _TextStyles.subtitle:
        return Theme.of(context).textTheme.headlineSmall;
      case _TextStyles.body:
        return Theme.of(context).textTheme.bodyLarge;
    }
  }

}

class CreativeWidgetsShowcase extends StatefulWidget {

  const CreativeWidgetsShowcase({
    super.key,
    required this.page,
    this.ad
  });

  final CreatorPage page;

  final BannerAd? ad;

  @override
  State<CreativeWidgetsShowcase> createState() => CreativeWidgetsShowcaseState();
}

class CreativeWidgetsShowcaseState extends State<CreativeWidgetsShowcase> {

  BlurredEdgesController _blurredEdgesController = BlurredEdgesController();

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> widgets = {
      'text': {
        'title': 'Text',
        'icon': RenderIcons.text,
      },
      'image': {
        'title': 'Image',
        'icon': RenderIcons.image,
        'onTap': () async {
          File? file = await FilePicker.imagePicker(context, crop: true, forceCrop: false);
          if (file == null) return;
          await ImageWidget.create(context, page: widget.page, file: file);
        }
      },
      'design_asset': {
        'title': 'Design Asset',
        'icon': RenderIcons.design_asset,
        'onTap': () async {
          String? option = await Alerts.optionsBuilder(
            context,
            title: 'Design Asset',
            options: [
              AlertOption(
                title: 'Upload SVG',
                id: 'svg'
              ),
              if (app.remoteConfig.enableIconFinder) AlertOption(
                title: 'Browse Design Assets',
                id: 'browse'
              ),
            ]
          );
          File? file;
          switch (option) {
            case 'svg':
              file = await FilePicker.pick(context: context, type: FileType.svg);
              break;
            case 'browse':
              file = await AppRouter.push(context, page: IconFinderScreen(project: widget.page.project));
              break;
            default:
          }
          if (file == null) return;
          await CreatorDesignAsset.create(context, page: widget.page, file: file);
        }
      },
      'pie-chart': {
        'title': 'Pie Chart',
        'icon': RenderIcons.pieChart
      },
      'shape': {
        'title': 'Shapes',
        'icon': RenderIcons.shapes
      },
      'qr_code': {
        'title': 'QR Code',
        'icon': RenderIcons.qr
      },
      'progress': {
        'title': 'Progress',
        'icon': RenderIcons.progress,
      },
      'box': {
        'title': 'Box',
        'icon': RenderIcons.box
      },
      'blob': {
        'title': 'Blob',
        'widget': Blob.random(
          size: 40,
          styles: BlobStyles(
            color: Palette.of(context).onSurfaceVariant,
          ),
        ),
      },
    };
    return AnimatedSize(
      duration: kAnimationDuration * 2,
      curve: Sprung.underDamped,
      child: SizedBox.fromSize(
        size: Editor.isHidden ? Size.fromHeight(Constants.of(context).bottomPadding + 48.0) : EditorManager.standardSize(context) + Offset(0, 48.0), // 48.0 (46.0 + 2) is the height calculated to match the size of editor (calculated from _kTabHeight in flutter/material/tabs.dart)
        child: Editor.isHidden ? Padding(
            padding: EdgeInsets.only(
              bottom: Constants.of(context).bottomPadding,
            ),
            child: Center(
              child: FilledTonalIconButton(
                onPressed: () {
                  Editor.isHidden = false;
                  setState(() { });
                },
                secondary: true,
                icon: Icon(
                  RenderIcons.arrow_up,
                  color: Palette.of(context).onSurfaceVariant,
                )
              ),
            ),
          ) : Container(
            margin: EdgeInsets.only(
              // top: widget.ad != null ? 0 : 48.0
            ),
            decoration: BoxDecoration(
              color: Palette.of(context).surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  spreadRadius: 0,
                )
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: BlurredEdgesView(
                    controller: _blurredEdgesController,
                    child: ListView.separated(
                      controller: _blurredEdgesController.scrollCtrl,
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 12,
                        bottom: 12 + (widget.ad != null ? 0 : Constants.of(context).bottomPadding),
                      ),
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, index) => SizedBox(width: 1),
                      itemBuilder: (context, index) {
                        String key = widgets.keys.elementAt(index);
                        Map<String, dynamic> cWidget = widgets[key]!;
                        return Tooltip(
                          message: cWidget['title'],
                          child: SizedBox(
                            width: 80,
                            child: InkWellButton(
                              radius: BorderRadius.circular(10),
                              onTap: () {
                                TapFeedback.light();
                                if (cWidget['onTap'] != null) cWidget['onTap']!();
                                else CreatorWidget.create(context, page: widget.page, id: key,);
                              },
                              child: (cWidget['icon'] != null) ? Icon(
                                cWidget['icon'],
                                color: Palette.of(context).onSurfaceVariant,
                                size: 30,
                              ) : Center(
                                child: cWidget['widget']
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: widgets.length,
                    ),
                  ),
                ),
                if (widget.ad != null) Expanded(
                  child: FadeInUp(
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      width: double.maxFinite,
                      padding: EdgeInsets.only(
                        bottom: Constants.of(context).bottomPadding,
                      ),
                      alignment: Alignment.center,
                      child: AdWidget(ad: widget.ad!),
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