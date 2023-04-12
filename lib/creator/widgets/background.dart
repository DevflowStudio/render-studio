import 'package:align_positioned/align_positioned.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

import '../../rehmat.dart';

class BackgroundWidget extends CreatorWidget {

  BackgroundWidget({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  // Inherited
  final String name = 'Background';
  @override
  final String id = 'background';

  bool isResizable = false;
  bool isBackgroundWidget = true;
  bool isDraggable = false;

  @override
  bool allowClipboard = false;

  // New to BackgroundWidget

  /// Color of the page background
  Color color = Colors.white;

  CreativeGradient? gradient;

  BackgroundType type = BackgroundType.color;

  CreativeImageProvider? imageProvider;

  @override
  Size get size => page.project.size.size;

  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 20, vertical: 20);
  
  @override
  List<EditorTab> get tabs => [
    EditorTab(
      tab: 'Page',
      options: [
        // Option.custom(
        //   widget: (context) => ButtonWithIcon(
        //     onTap: (context) => page.widgets.showAddWidgetModal(context),
        //     icon: RenderIcons.add,
        //     title: 'Add',
        //     backgroundColor: Palette.of(context).primary.harmonizeWith(page.palette.background),
        //     foregroundColor: Palette.of(context).onPrimary,
        //     showBorder: false,
        //     animateBorderRadius: false,
        //     borderRadius: 15,
        //   ),
        // ),
        Option.button(
          icon: RenderIcons.palette,
          title: 'Palette',
          tooltip: 'Tap to shuffle palette',
          onTap: (context) async {
            bool hasChanged = false;
            await EditorTab.modal(
              context,
              tab: (context, setState) => EditorTab.palette(
                page: page,
                onSelected: (palette) {
                  page.updatePalette(palette);
                  hasChanged = true;
                  updateListeners(WidgetChange.misc);
                },
              ),
              padding: EdgeInsets.only(
                left: 6,
                right: 6,
                top: 6,
                bottom: Constants.of(context).bottomPadding
              )
            );
            if (hasChanged) updateListeners(WidgetChange.update, historyMessage: 'Change Palette');
          },
        ),
        Option.color(
          palette: page.palette,
          onChange: (color) {
            if (color == null) return;
            this.color = color;
            gradient = null;
            if (type != BackgroundType.color) {
              changeBackgroundType(BackgroundType.color);
            }
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (color) {
            if (color != null) this.color = color;
            if (type != BackgroundType.color) {
              changeBackgroundType(BackgroundType.color);
            }
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          title: 'Gradient',
          onTap: (context) async {
            gradient ??= CreativeGradient.fromPalette(palette: page.palette);
            updateListeners(WidgetChange.misc);
            await EditorTab.modal(
              context,
              actions: [
                IconButton(
                  onPressed: () {
                    gradient = null;
                    Navigator.of(context).pop();
                  },
                  icon: Icon(RenderIcons.delete)
                ),
              ],
              tab: (context, setState) => gradient!.getEditor(
                palette: page.palette,
                allowOpacity: false,
                onChange: (change) {
                  setState(() {});
                  updateListeners(change);
                },
              ),
            );
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.gradient
        ),
        Option.button(
          icon: RenderIcons.image,
          title: (asset != null && imageProvider != null) ? 'Edit Image' : 'Add Image',
          tooltip: (asset != null && imageProvider != null) ? 'Edit background image' : 'Tap to add an image to the background',
          onTap: (context) async {
            if (asset != null && imageProvider != null) EditorTab.modal(
              context,
              height: 90,
              tab: (context, setState) => imageProvider!.editor(
                asset!,
                onChange: (change) {
                  updateListeners(change);
                },
                name: 'Image Editor',
                options: [
                  Option.button(
                    icon: RenderIcons.image,
                    title: 'Replace',
                    tooltip: 'Tap to replace image',
                    onTap: (context) async {
                      File? file = await FilePicker.imagePicker(context, crop: true, cropRatio: page.project.size.cropRatio);
                      if (file == null) return;
                      asset!.logVersion(version: page.history.nextVersion ?? '', file: file);
                      updateListeners(WidgetChange.update);
                    },
                  ),
                  Option.button(
                    icon: RenderIcons.delete,
                    title: 'Remove Image',
                    tooltip: 'Tap to remove image',
                    onTap: (context) async {
                      asset = null;
                      imageProvider = null;
                      changeBackgroundType(BackgroundType.color);
                      updateListeners(WidgetChange.update);
                      Navigator.of(context).pop();
                    },
                  ),
                ]
              )
            ); else {
              File? file = await FilePicker.imagePicker(context, crop: true, cropRatio: page.project.size.cropRatio);
              if (file == null) return;
              if (asset == null) {
                asset = Asset.create(page: page, file: file);
                imageProvider = CreativeImageProvider.create(this);
              } else {
                asset!.logVersion(version: page.history.nextVersion ?? '', file: file);
              }
              changeBackgroundType(BackgroundType.image);
              updateListeners(WidgetChange.update);
            }
          },
        ),
        Option.button(
          icon: RenderIcons.resize,
          title: 'Resize',
          tooltip: 'Tap to resize the project',
          onTap: (context) async {
            EditorTab.modal(
              context,
              tab: (context, setState) => EditorTab.pickerBuilder(
                title: 'Resize Project',
                itemBuilder: (context, index) => Text('${PostSizePresets.values[index].title}'),
                childCount: PostSizePresets.values.length,
                onSelectedItemChanged: (index) {
                  page.project.size = PostSizePresets.values[index].toSize();
                  page.notifyListeners(PageChange.misc);
                },
              )
            );
          },
        ),
        Option.button(
          title: 'Padding',
          onTap: (context) async {
            updateGrids(showGridLines: true, hideCenterGrids: true);
            await EditorTab.modal(
              context,
              tab: (context, setState) => EditorTab.paddingEditor(
                padding: padding,
                max: page.project.contentSize.width/8,
                min: 5,
                onChange: (value) {
                  padding = value;
                  updateGrids(showGridLines: true, hideCenterGrids: true);
                  updateListeners(WidgetChange.misc);
                },
              )
            );
            updateGrids(showGridLines: false);
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.padding,
          tooltip: 'Adjust Padding'
        ),
        if (page.project.pages.length > 1) Option.button(
          icon: RenderIcons.delete,
          title: 'Delete Page',
          tooltip: 'Tap to delete this page',
          onTap: (context) async {
            bool delete = await Alerts.showConfirmationDialog(
              context,
              title: 'Delete Page?',
              message: 'Are you sure you want to delete this page and all of it\'s content? This cannot be reverted.',
              isDestructive: true,
              confirmButtonText: 'Delete'
            );
            if (delete) {
              page.project.pages.delete();
              Alerts.snackbar(context, text: 'Deleted page');
            }
          },
        ),
      ],
    )
  ];

  @override
  Widget build(BuildContext context, {
    bool isInteractive = true,
  }) => AlignPositioned(
    dx: position.dx,
    dy: position.dy,
    touch: Touch.inside,
    child: widget(context),
  );

  @override
  Widget widget(BuildContext context) {
    if (asset == null) type = BackgroundType.color;
    return GestureDetector(
      onTap: () => page.widgets.select(this),
      child: Container(
        decoration: BoxDecoration(
          color: type == BackgroundType.color ? color : Colors.white,
          gradient: gradient?.gradient
        ),
        child: (asset != null && imageProvider != null) ? imageProvider!.build(
          asset!,
          size: size,
        ) : null,
      ),
    );
  }

  @override
  void updateListeners(
    /// Type of change when notifying listeners
    /// Affects the history of the widget
    WidgetChange change, {
    /// Pass `true` to remove all grids
    bool removeGrids = false,
    String? historyMessage,
  }) {
    if (removeGrids) page.gridState.hideAll();
    if (change == WidgetChange.update) {
      notifyListeners(change);
      if (asset != null) asset!.logVersion(version: page.history.nextVersion ?? '', file: asset!.file);
      page.history.log(historyMessage);
    }
    stateCtrl.update(change);
  }

  @override
  void updateGrids({
    bool realtime = false,
    bool showGridLines = false,
    bool createGrids = true,
    bool snap = true,
    double? snapSensitivity,
    Offset? position,
    bool hideCenterGrids = false
  }) {
    page.gridState.grids.removeWhere((grid) => grid.widget == this);
    Color gridColor = Colors.pinkAccent;
    // if (type == BackgroundType.color) {
    //   gridColor = page.palette.onBackground;
    // } else {
    //   gridColor = Colors.white;
    // }
    // Color gridColor = Colors.deepPurple;
    List<Grid> grids = [
      Grid(
        position: Offset(
          - page.project.contentSize.width/2 + padding.left,
          0
        ),
        color: gridColor,
        layout: GridLayout.vertical,
        gridWidgetPlacement: GridWidgetPlacement.left,
        widget: this,
        page: page,
        dotted: false
      ),
      Grid(
        position: Offset(
          page.project.contentSize.width/2 - padding.right,
          0
        ),
        color: gridColor,
        layout: GridLayout.vertical,
        gridWidgetPlacement: GridWidgetPlacement.right,
        widget: this,
        page: page,
        dotted: false
      ),
      Grid(
        position: Offset(
          0,
          page.project.contentSize.height/2 - padding.bottom,
        ),
        color: gridColor,
        layout: GridLayout.horizontal,
        gridWidgetPlacement: GridWidgetPlacement.bottom,
        widget: this,
        page: page,
        dotted: false
      ),
      Grid(
        position: Offset(
          0,
          - page.project.contentSize.height/2 + padding.top,
        ),
        color: gridColor,
        layout: GridLayout.horizontal,
        gridWidgetPlacement: GridWidgetPlacement.top,
        widget: this,
        page: page,
        dotted: false
      ),
      if (!hideCenterGrids) Grid(
        position: const Offset(0, 0),
        color: gridColor,
        layout: GridLayout.vertical,
        widget: this,
        page: page,
        gridWidgetPlacement: GridWidgetPlacement.centerVertical,
        dotted: false
      ),
      if (!hideCenterGrids) Grid(
        position: const Offset(0, 0),
        color: gridColor,
        layout: GridLayout.horizontal,
        widget: this,
        page: page,
        gridWidgetPlacement: GridWidgetPlacement.centerHorizontal,
        dotted: false
      )
    ];
    grids.forEach((element) {
      element.isVisible = showGridLines;
    });
    page.gridState.grids.addAll(grids);
    page.gridState.notifyListeners();
  }

  void changeBackgroundType(BackgroundType _type) {
    switch (_type) {
      case BackgroundType.color:
        asset = null;
        imageProvider = null;
        break;
      case BackgroundType.image:
        gradient = null;
        break;
      default:
    }
    type = _type;
    updateListeners(WidgetChange.misc);
  }

  void onPaletteUpdate() {
    color = page.palette.background;
    updateListeners(WidgetChange.misc);
  }

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) {
    if (asset != null && type != BackgroundType.image && buildInfo.buildType == BuildType.save) {
      asset!.delete();
      asset = null;
      imageProvider = null;
    }
    return {
      ... super.toJSON(buildInfo: buildInfo),
      'color': color.toHex(),
      'gradient': gradient?.toJSON(),
      'padding': padding.toJSON(),
      'image-provider': imageProvider?.toJSON(),
    };
  }

  @override
  void buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);
    try {
      color = HexColor.fromHex(json['color']);
      if (asset != null) {
        type = BackgroundType.image;
      }
      if (json['gradient'] != null) try {
        gradient = CreativeGradient.fromJSON(Map.from(json['gradient']));
      } catch (e) { }
      if (json['padding'] != null) {
        padding = PaddingExtension.fromJSON(Map.from(json['padding']));
      }
      if (json['image-provider'] != null) {
        imageProvider = CreativeImageProvider.fromJSON(Map.from(json['image-provider']), widget: this);
      }
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'Error building background', stacktrace: stacktrace);
      throw WidgetCreationException(
        'Failed to create background widget',
        details: 'Error: $e'
      );
    }
  }

}

enum BackgroundType {
  color,
  image
}