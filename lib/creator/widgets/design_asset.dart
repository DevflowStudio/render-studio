import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:universal_io/io.dart';

import '../../rehmat.dart';

class CreatorDesignAsset extends CreatorWidget {

  CreatorDesignAsset({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create(BuildContext context, {
    required CreatorPage page
  }) async {
    CreatorDesignAsset designAsset = CreatorDesignAsset(page: page);
    File? _file = await CreatorDesignAsset.buildOptionsForAsset(context, page: page);
    if (_file == null) return null;
    designAsset.asset = Asset.create(project: page.project, file: _file, buildInfo: BuildInfo(buildType: BuildType.unknown, version: page.history.nextVersion));
    page.widgets.add(designAsset);
  }

  // Inherited
  String name = 'Design Asset';
  @override
  final String id = 'design_asset';

  bool keepAspectRatio = true;
  bool isResizable = true;
  bool isDraggable = true;

  @override
  Size size = Size(100, 100);
  @override
  Size? minSize = Size(20, 20);

  Color? color;
  
  @override
  List<ResizeHandler> resizeHandlers = [
    ResizeHandler.topLeft,
    ResizeHandler.topRight,
    ResizeHandler.bottomLeft,
    ResizeHandler.bottomRight
  ];

  @override
  List<EditorTab> get tabs => [
    EditorTab(
      options: [
        Option.button(
          title: 'Replace',
          tooltip: 'Replace the asset file',
          onTap: (context) async {
            File? _file = await CreatorDesignAsset.buildOptionsForAsset(context, page: page);
            if (_file == null) return null;
            color = null;
            asset?.logVersion(version: page.history.nextVersion ?? '', file: _file);
            updateListeners(WidgetChange.update);
          },
          icon: RenderIcons.replace
        ),
        Option.color(
          title: 'Color',
          tooltip: 'Tap to select asset color',
          onChange: (_color) async {
            if (_color == null) return;
            color = _color;
            updateListeners(WidgetChange.misc);
          },
          onChangeEnd: (color) {
            updateListeners(WidgetChange.update);
          },
        ),
        ... defaultOptions,
      ],
      tab: 'Design Asset',
    ),
    EditorTab(
      tab: 'Adjust',
      options: [
        Option.rotate(
          widget: this,
        ),
        Option.scale(
          widget: this,
        ),
        Option.opacity(
          widget: this,
        ),
        Option.nudge(
          widget: this,
        ),
      ]
    )
  ];

  @override
  Widget widget(BuildContext context) => MeasureSize(
    onChange: (size) { },
    child: SvgPicture.file(
      asset!.file,
      color: color,
    )
  );

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown
  }) => {
    ... super.toJSON(buildInfo: buildInfo),
    'color': color?.toHex(),
  };

  @override
  void buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);
    try {
      if (asset == null) throw WidgetCreationException('Could not build Design Asset. File may have been deleted.');
      if (json['color'] != null) color = HexColor.fromHex(json['color']);
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'error building design asset from json', stacktrace: stacktrace);
      throw WidgetCreationException(
        'Error building Design Asset.',
        details: 'Error building Design Asset from JSON: $e'
      );
    }
  }

  @override
  void updateListeners(
    /// Type of change when notifying listeners
    /// Affects the history of the widget
    WidgetChange change, {
    /// Pass `true` to remove all grids
    bool removeGrids = false
  }) {
    super.updateListeners(change, removeGrids: removeGrids);
  }

  @override
  Future<void> onDuplicate() async {
    asset = await asset!.duplicate(buildInfo: BuildInfo(buildType: BuildType.unknown, version: page.history.nextVersion));
    updateListeners(WidgetChange.misc);
  }

  @override
  void onDelete() {
    // page.project.assetManager.delete(asset);
  }

  void onPaletteUpdate() {
    if (color != null) color = page.palette.onBackground;
    updateListeners(WidgetChange.misc);
  }

  static Future<File?> buildOptionsForAsset(BuildContext context, {
    required CreatorPage page
  }) async {
    String? option = await Alerts.optionsBuilder(
      context,
      title: 'Design Asset',
      options: [
        AlertOption(title: 'Choose SVG', id: 'svg'),
        AlertOption(title: 'IconFinder', id: 'iconfinder'),
      ]
    );
    File? file;
    switch (option) {
      case 'svg':
        file = await FilePicker.pick(context: context, type: FileType.svg,);
        break;
      case 'iconfinder':
        file = await AppRouter.push(context, page: IconFinderScreen(project: page.project,));
        break;
      default:
    }
    return file;
  }

}