import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../rehmat.dart';

class Spinner extends StatefulWidget {

  final Color? valueColor;
  final Color? backgroundColor;
  final double strokeWidth;
  final double? value;

  const Spinner({Key? key, this.valueColor, this.backgroundColor, this.strokeWidth = 4.0, this.value}) : super(key: key);

  static Future<void> fullscreen(
    BuildContext context, {
      /// Provide a function that will be executed
      required Future<void> Function() task,
      Function? onComplete
    }
  ) async {
    showModal(
      context: context,
      builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent
        ),
        child: WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Palette.of(context).background.withOpacity(0.3),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: const Center(
                child: Spinner(
                  valueColor: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await task();
    Navigator.of(context).pop();
    if (onComplete != null) onComplete();
  }

  @override
  _SpinnerState createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> {

  @override
  Widget build(BuildContext context) {
    Color color;
    color = widget.valueColor ?? Palette.light.primary;
    return CircularProgressIndicator(
      backgroundColor: widget.backgroundColor,
      strokeWidth: widget.strokeWidth,
      value: widget.value,
      valueColor: AlwaysStoppedAnimation(color),
    );
  }
  
}