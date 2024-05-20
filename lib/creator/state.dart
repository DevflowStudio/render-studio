import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import '../rehmat.dart';

class RenderWidgetStateController extends PropertyChangeNotifier<WidgetChange> {

  final CreatorWidget widget;
  // Key key = UniqueKey();

  RenderWidgetStateController(this.widget);

  // void renewKey() => key = UniqueKey();

  void update([WidgetChange? property]) => notifyListeners(property);

}

class RenderWidgetState extends StatefulWidget {
  
  RenderWidgetState({
    Key? key,
    required this.controller,
    required this.widget,
    required this.page,
  }) : super(key: key);

  final RenderWidgetStateController controller;
  final CreatorWidget widget;
  final CreatorPage page;

  @override
  State<RenderWidgetState> createState() => _RenderWidgetStateState();
}

class _RenderWidgetStateState extends State<RenderWidgetState> {

  @override
  void initState() {
    widget.controller.addListener(onUpdate);
    widget.page.addListener(onUpdate);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(onUpdate);
    widget.page.removeListener(onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(),
      child: widget.widget.build(context)
    );
  }

  void onUpdate() => setState(() { });

}