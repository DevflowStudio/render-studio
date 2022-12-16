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

  List<Color>? gradient;
  BackgroundGradient gradientType = BackgroundGradient.type2;

  BackgroundType type = BackgroundType.color;

  CreativeImageProvider? imageProvider;

  @override
  Size get size => page.project.size!.size;

  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 20, vertical: 20);
  
  @override
  List<EditorTab> get tabs => [
    EditorTab(
      tab: 'Page',
      options: [
        Option.button(
          icon: RenderIcons.add,
          title: 'Widget',
          tooltip: 'Add a new widget',
          onTap: (context) => page.widgets.showAddWidgetModal(context),
        ),
        if (page.widgets.nSelections >= 2 && page.widgets.multiselect) Option.button(
          icon: RenderIcons.group,
          title: 'Group',
          tooltip: 'Group the selected widgets',
          onTap: (context) {
            WidgetGroup.create(page: page);
          }
        ),
        Option.toggle(
          disabledIcon: RenderIcons.multiselect,
          enabledIcon: RenderIcons.multiselectDisabled,
          title: 'Multiselect',
          enabledTooltip: 'Tap to disable multiselect',
          disabledTooltip: 'Tap to enable multiselect',
          value: page.widgets.multiselect,
          onChange: (value) {
            page.widgets.multiselect = value;
            updateListeners(WidgetChange.misc);
          },
        ),
        Option.button(
          icon: RenderIcons.resize,
          title: 'Resize',
          tooltip: 'Tap to resize the project',
          onTap: (context) async {
            EditorTab.modal(
              context,
              tab: EditorTab.pickerBuilder(
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
          icon: RenderIcons.palette,
          title: 'Palette',
          tooltip: 'Tap to shuffle palette',
          onTap: (context) async {
            await EditorTab.modal(
              context,
              tab: EditorTab.palette(
                page: page,
                onSelected: (palette) {
                  page.updatePalette(palette);
                  updateListeners(WidgetChange.misc);
                },
              ),
              padding: EdgeInsets.only(
                left: 6,
                right: 6,
                top: 6,
                bottom: MediaQuery.of(context).padding.bottom
              )
            );
            updateListeners(WidgetChange.update);
          },
        ),
        Option.button(
          title: 'Padding',
          onTap: (context) async {
            updateGrids(showGridLines: true);
            await EditorTab.modal(
              context,
              height: 200,
              tab: EditorTab.paddingEditor(
                padding: padding,
                max: page.project.contentSize.width/8,
                min: 5,
                onChange: (value) {
                  padding = value;
                  updateGrids(showGridLines: true);
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
        Option.color(
          onChange: (color) {
            if (color == null) return;
            this.color = color;
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
          icon: RenderIcons.image,
          title: 'Image',
          tooltip: 'Tap to select an image as background',
          onTap: (context) async {
            File? file = await FilePicker.imagePicker(context, crop: true, cropRatio: page.project.size!.cropRatio);
            if (file == null) return;
            if (asset == null) {
              asset = Asset.create(project: page.project, file: file);
              imageProvider = CreativeImageProvider.create(this);
            } else {
              asset!.logVersion(version: page.history.nextVersion ?? '', file: file);
            }
            changeBackgroundType(BackgroundType.image);
            updateListeners(WidgetChange.update);
          },
        ),
        if (page.project.pages.length > 1) Option.button(
          icon: RenderIcons.delete,
          title: 'Delete Page',
          tooltip: 'Tap to delete this page',
          onTap: (context) async {
            bool delete = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Page?'),
                content: const Text('Are you sure you want to delete this page and all of it\'s content? This cannot be reverted.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel')
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete')
                  ),
                ],
              ),
            );
            if (delete) {
              page.project.pages.delete();
              Alerts.snackbar(context, text: 'Deleted page');
            }
          },
        ),
      ],
    ),
    if (asset != null && imageProvider != null) imageProvider!.editor(
      asset!,
      onChange: (change) {
        updateListeners(change);
      },
      name: 'Image Editor',
      options: [
        Option.button(
          title: 'Remove Image',
          onTap: (context) {
            asset = null;
            imageProvider = null;
            changeBackgroundType(BackgroundType.color);
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.remove
        ),
        Option.button(
          icon: RenderIcons.image,
          title: 'Replace',
          tooltip: 'Tap to replace image',
          onTap: (context) async {
            File? file = await FilePicker.imagePicker(context, crop: true, cropRatio: page.project.size!.cropRatio);
            if (file == null) return;
            asset!.logVersion(version: page.history.nextVersion ?? '', file: file);
            updateListeners(WidgetChange.update);
          },
        ),
      ]
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
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: type == BackgroundType.color ? color : Colors.white,
          gradient: (type == BackgroundType.gradient && gradient != null) ? LinearGradient(
            colors: gradient!,
            begin: gradientType.begin,
            end: gradientType.end,
          ) : null
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
    bool removeGrids = false
  }) {
    if (removeGrids) page.gridState.visible.clear();
    if (change == WidgetChange.update) notifyListeners(change);
    stateCtrl.update(change);
    if (change == WidgetChange.update && asset != null) {
      asset!.logVersion(version: page.history.nextVersion ?? '', file: asset!.file);
    }
  }

  @override
  void updateGrids({
    bool realtime = false,
    bool showGridLines = false,
    bool createGrids = true,
    bool snap = true,
    double? snapSensitivity,
    Offset? position
  }) {
    page.gridState.grids.removeWhere((grid) => grid.widget == this);
    Color gridColor;
    if (type == BackgroundType.color) {
      gridColor = page.palette.onBackground;
    } else {
      gridColor = Colors.white;
    }
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
      )
    ];
    page.gridState.grids.addAll(grids);
    page.gridState.visible.removeWhere((grid) => grid.widget == this);
    if (showGridLines) page.gridState.visible.addAll(grids);
    page.gridState.notifyListeners();
  }

  void changeBackgroundType(BackgroundType _type) {
    switch (_type) {
      case BackgroundType.color:
        asset = null;
        gradient = null;
        imageProvider = null;
        break;
      case BackgroundType.image:
        gradient = null;
        break;
      case BackgroundType.gradient:
        asset = null;
        imageProvider = null;
        break;
      default:
    }
    type = _type;
    updateListeners(WidgetChange.misc);
  }

  List<String>? _generateGradientsHex() {
    List<String> _generated = [];
    if (gradient == null) return null;
    for (Color color in gradient!) {
      _generated.add(color.toHex());
    }
    return _generated;
  }

  List<Color> _generateGradientsColor(List<String> hex) {
    List<Color> _generated = [];
    for (String h in hex) {
      _generated.add(HexColor.fromHex(h));
    }
    return _generated;
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
      'gradient': _generateGradientsHex(),
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
      if (json['gradient'] != null) {
        gradient = _generateGradientsColor(json['gradient']);
        type = BackgroundType.gradient;
      }
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
  gradient,
  image
}

enum BackgroundGradient {
  type1,
  type2,
  type3,
  type4,
}

extension BackgroundGradientExtension on BackgroundGradient {

  AlignmentGeometry get begin {
    switch (this) {
      case BackgroundGradient.type1:
        return Alignment.centerLeft;
      case BackgroundGradient.type2:
        return Alignment.topLeft;
      case BackgroundGradient.type3:
        return Alignment.topCenter;
      case BackgroundGradient.type4:
        return Alignment.topRight;
      default:
        return Alignment.topLeft;
    }
  }

  AlignmentGeometry get end {
    switch (this) {
      case BackgroundGradient.type1:
        return Alignment.centerRight;
      case BackgroundGradient.type2:
        return Alignment.bottomRight;
      case BackgroundGradient.type3:
        return Alignment.bottomCenter;
      case BackgroundGradient.type4:
        return Alignment.bottomLeft;
      default:
        return Alignment.bottomRight;
    }
  }

}