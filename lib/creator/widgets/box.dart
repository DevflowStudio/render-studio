import 'package:flutter/material.dart';
import '../../rehmat.dart';

class CreatorBoxWidget extends CreatorWidget {

  CreatorBoxWidget({required CreatorPage page, Map? data, BuildInfo buildInfo = BuildInfo.unknown}) : super(page, data: data, buildInfo: buildInfo);

  static Future<void> create(BuildContext context, {
    required CreatorPage page
  }) async {
    CreatorBoxWidget widget = CreatorBoxWidget(page: page);
    page.widgets.add(widget);
  }

  @override
  void onInitialize() {
    containerProvider = CreativeContainerProvider.create(this, color: page.palette.secondary);
    super.onInitialize();
  }

  // Inherited
  final String name = 'Box';
  @override
  final String id = 'box';

  bool keepAspectRatio = false;
  bool isResizable = true;
  bool isDraggable = true;

  @override
  Size size = Size(100, 100);
  @override
  Size? minSize = Size(20, 10);

  BackgroundType type = BackgroundType.color;

  late CreativeContainerProvider containerProvider;

  double blur = 0;
  
  @override
  List<ResizeHandler> resizeHandlers = [
    ResizeHandler.topLeft,
    ResizeHandler.topCenter,
    ResizeHandler.topRight,
    ResizeHandler.centerLeft,
    ResizeHandler.centerRight,
    ResizeHandler.bottomLeft,
    ResizeHandler.bottomCenter,
    ResizeHandler.bottomRight
  ];

  @override
  List<EditorTab> get tabs => [
    containerProvider.editor(
      name: 'Box',
      showPadding: false,
      onChange: (change) {
        updateListeners(change);
      },
      options: [
        ... defaultOptions
      ]
    ),
    EditorTab.adjustTab(widget: this)
  ];

  @override
  Widget widget(BuildContext context) => containerProvider.build();

  @override
  Map<String, dynamic> toJSON({
    BuildInfo buildInfo = BuildInfo.unknown,
  }) => {
    ... super.toJSON(buildInfo: buildInfo),
    'container-provider': containerProvider.toJSON(buildToUniversal: buildInfo.buildType == BuildType.save),
  };

  @override
  bool buildFromJSON(Map<String, dynamic> json, {
    required BuildInfo buildInfo
  }) {
    super.buildFromJSON(json, buildInfo: buildInfo);
    bool isBuildingFromUniversalBuild = json['properties']['is-universal-build'] ?? false;
    try {
      if (json['container-provider'] != null) {
        containerProvider = CreativeContainerProvider.fromJSON(json['container-provider'], widget: this, isBuildingFromUniversal: isBuildingFromUniversalBuild);
      }
      blur = json['blur'] ?? 0;
      return true;
    } catch (e) {
      return false;
    }
  }

}