import 'package:flutter/material.dart';

import '../../rehmat.dart';

class Editor extends StatefulWidget {
  
  const Editor({
    Key? key,
    required this.tabs,
    required this.project,
    required this.page,
    required this.widget,
  }) : super(key: key);

  final List<EditorTab> tabs;
  final Project project;
  final CreatorPage page;
  final CreatorWidget widget;

  Widget get build => this;

  Future<void> showTab(BuildContext context, {
    required EditorTab tab,
    double? height
  }) async {
    await showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      builder: (context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Palette.of(context).surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              spreadRadius: 0,
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 45
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    tab.tab,
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(),
                  ),
                ),
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.check_circle)
                ),
              ],
            ),
            const Divider(
              indent: 0,
              height: 0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 20, bottom: 20),
              child: SizedBox.fromSize(
                size: Size.fromHeight(MediaQuery.of(context).size.height/9),
                child: tab.build(context),
              ),
            ),
          ],
        )
      ),
    );
  }

  static Size calculateSize(BuildContext context) {
    Size editorSize = Size(double.infinity, MediaQuery.of(context).size.height * 0.25); // The editor can only be allowed to cover 23% of the screen area.
    if (MediaQuery.of(context).size.height * 0.25 > 180) editorSize = Size(double.infinity, 180);
    return editorSize;
  }

  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> with TickerProviderStateMixin {

  @override
  void initState() {
    widget.widget.addListener(onPropertyChange);
    super.initState();
  }

  @override
  void dispose() {
    widget.widget.removeListener(onPropertyChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size editorSize = Editor.calculateSize(context);
    return DefaultTabController(
      length: widget.tabs.length,
      child: SizedBox.fromSize(
        size: editorSize,
        child: Container(
          decoration: BoxDecoration(
            color: App.getThemedObject(context, light: Colors.white, dark: Palette.of(context).surface),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                spreadRadius: 0,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TabBar(
                enableFeedback: true,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: App.getThemedBlackAndWhite(context),
                labelColor: App.getThemedBlackAndWhite(context),
                indicator: widget.tabs.length > 1 ? null : const BoxDecoration(),
                unselectedLabelColor: App.getThemedBlackAndWhite(context).withOpacity(0.5),
                isScrollable: true,
                labelStyle: Theme.of(context).textTheme.subtitle2,
                tabs: List.generate(
                  widget.tabs.length,
                  (index) => Tab(
                    text: widget.tabs[index].tab,
                  )
                )
              ),
              const Divider(
                indent: 0,
                height: 0,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Container(
                    // color: Colors.yellow,
                    child: SizedBox.fromSize(
                      size: Size.fromHeight(editorSize.height * 3/5),
                      child: Center(
                        child: SizedBox.fromSize(
                          size: Size.fromHeight(editorSize.height * 1.1/2),
                          child: Container(
                            // color: Colors.red,
                            child: TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              children: List.generate(
                                widget.tabs.length,
                                (index) {
                                  return widget.tabs[index].build(context);
                                }
                              )
                            ),
                          ),
                        ),
                      )
                    ),
                  ),
                ),
              )
            ],
          )
        ),
      ),
    );
  }

  void onPropertyChange() {
    setState(() { });
  }

}

class EditorTab {

  EditorTab({
    required this.options,
    required this.tab,
    this.type = EditorTabType.row,
  });

  final List<Option> options;
  final String tab;
  final EditorTabType type;

  Widget build(BuildContext context) {
    switch (type) {
      case EditorTabType.row:
        return ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: options[index].build(context),
          ),
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
        );
      case EditorTabType.column:
        return ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (context, index) => options[index].build(context),
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.zero,
        );
      case EditorTabType.single:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            options[0].build(context)
          ],
        );
      case EditorTabType.grid:
        return SizedBox(
          height: 80,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: options.length ~/ 2),
            itemBuilder: (context, index) => Container(
              color: Colors.red.withOpacity(0.2),
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(5),
              child: options[index].build(context),
            ),
            itemCount: options.length,
            // physics: NeverScrollableScrollPhysics(),
          ),
        );
      default:
    }
    return Container();
  }

  static EditorTab opacity({
    required double opacity,
    required Function(double value) onChange,
    Function(double value)? onChangeEnd,
    Function(double value)? onChangeStart,
  }) => EditorTab(
    type: EditorTabType.single,
    options: [
      Option.slider(
        value: opacity,
        min: 0.05,
        max: 1,
        onChangeStart: onChangeStart,
        onChange: onChange,
        onChangeEnd: onChangeEnd,
      )
    ],
    tab: 'Opacity'
  );

  static EditorTab rotate({
    required double angle,
    required Function(double value) onChange,
    Function(double value)? onChangeEnd,
    Function(double value)? onChangeStart,
  }) => EditorTab(
    type: EditorTabType.single,
    options: [
      Option.slider(
        value: angle,
        min: 0,
        max: 360,
        onChangeStart: onChangeStart,
        onChange: onChange,
        onChangeEnd: onChangeEnd,
        divisions: 45
      )
    ],
    tab: 'Rotate'
  );

  static EditorTab nudge({
    required Function(double dx) onDXchange,
    required Function(double dy) onDYchange,
  }) => EditorTab(
    type: EditorTabType.single,
    options: [
      Option.custom(
        widget: (context) => Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: () {
                onDYchange(-Constants.nudgeSenstivity);
                TapFeedback.light();
              },
              child: Container(
                width: 60,
                height: 35,
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: Palette.of(context).secondaryContainer,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Icon(
                  Icons.arrow_upward,
                  color: Palette.of(context).onSecondaryContainer,
                )
              ),
            ),
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () {
                    onDXchange(-Constants.nudgeSenstivity);
                    TapFeedback.light();
                  },
                  child: Container(
                    width: 60,
                    height: 35,
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                    decoration: BoxDecoration(
                      color: Palette.of(context).secondaryContainer,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Palette.of(context).onSecondaryContainer,
                    )
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () {
                    onDYchange(Constants.nudgeSenstivity);
                    TapFeedback.light();
                  },
                  child: Container(
                    width: 60,
                    height: 35,
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                    decoration: BoxDecoration(
                      color: Palette.of(context).secondaryContainer,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Icon(
                      Icons.arrow_downward,
                      color: Palette.of(context).onSecondaryContainer,
                    )
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () {
                    onDXchange(Constants.nudgeSenstivity);
                    TapFeedback.light();
                  },
                  child: Container(
                    width: 60,
                    height: 35,
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                    decoration: BoxDecoration(
                      color: Palette.of(context).secondaryContainer,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Palette.of(context).onSecondaryContainer
                    )
                  ),
                ),
              ]
            )
          ],
        ),
      )
    ],
    tab: 'Nudge'
  );

}

enum EditorTabType {
  /// Arrange the options in a list
  row,
  column,
  /// Arrange the options in a grid
  grid,
  /// Center align the single widget
  single
}

extension EditorTabTypeExtension on EditorTabType {

  // Size get size {
  //   switch (this) {
  //     case EditorTabType.row:
  //       return const Size(double.maxFinite, 90);
  //     case EditorTabType.column:
  //       return const Size(double.maxFinite, 90);
  //     default:
  //       return const Size(double.maxFinite, 90);
  //   }
  // }

}