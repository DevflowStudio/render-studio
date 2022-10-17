import 'package:flutter/material.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import '../rehmat.dart';

class WidgetStateController extends PropertyChangeNotifier<WidgetChange> {

  final CreatorWidget widget;
  // Key key = UniqueKey();

  WidgetStateController(this.widget);

  // void renewKey() => key = UniqueKey();

  void update([WidgetChange? property]) => notifyListeners(property);

}

class WidgetState extends StatefulWidget {
  
  WidgetState({
    Key? key,
    required this.controller,
    required this.creator_widget,
    required this.context
  }) : super(key: key);

  final WidgetStateController controller;
  final CreatorWidget creator_widget;
  final BuildContext context;

  @override
  State<WidgetState> createState() => _WidgetStateState();
}

class _WidgetStateState extends State<WidgetState> {

  @override
  void initState() {
    widget.controller.addListener(onUpdate);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(),
      child: widget.creator_widget.build(widget.context)
    );
  }

  void onUpdate() => setState(() { });

}