import 'package:universal_io/io.dart';
import 'dart:ui';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../rehmat.dart';

class Spinner extends StatefulWidget {

  final Color? valueColor;
  final Color? backgroundColor;
  final double strokeWidth;
  final double? value;
  final bool adaptive;

  const Spinner({Key? key, this.valueColor, this.backgroundColor, this.strokeWidth = 4.0, this.value, this.adaptive = false}) : super(key: key);

  static Future<void> fullscreen(
    BuildContext context, {
      /// Provide a function that will be executed
      required Future<void> Function() task,
      Function? onComplete
    }
  ) async {
    showCupertinoDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Palette.of(context).background.withOpacity(0.2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(
              child: Platform.isIOS ? CupertinoActivityIndicator(
                color: Constants.getThemedBlackAndWhite(context),
                radius: 15,
              ) : SpinKitThreeBounce(
                color: Constants.getThemedBlackAndWhite(context),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
    try {
      await task();
    } catch (e) {
      analytics.logError(e);
    }
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
    color = widget.valueColor ?? Theme.of(context).progressIndicatorTheme.color ?? Palette.of(context).primary;
    if (!widget.adaptive || (widget.adaptive && Platform.isAndroid)) return CircularProgressIndicator(
      backgroundColor: widget.backgroundColor,
      strokeWidth: widget.strokeWidth,
      value: widget.value,
      valueColor: AlwaysStoppedAnimation(color),
    ); else return CupertinoActivityIndicator(
      color: Constants.getThemedObject(context, light: Colors.grey, dark: Colors.grey[200]),
    );
  }
  
}

class TitleSpinner extends StatelessWidget {
  
  const TitleSpinner({
    Key? key,
    required this.controller,
    required this.title
  }) : super(key: key);

  final LoadingController controller;

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlipCard(
          front: title,
          controller: controller.flipCardController,
          back: TitleSpinnerWidget(),
          flipOnTouch: false,
          direction: FlipDirection.VERTICAL,
        )
      ],
    );
  }

}

class TitleSpinnerWidget extends StatefulWidget {

  const TitleSpinnerWidget({Key? key}) : super(key: key);

  @override
  State<TitleSpinnerWidget> createState() => _TitleSpinnerWidgetState();
}

class _TitleSpinnerWidgetState extends State<TitleSpinnerWidget> {
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? CupertinoActivityIndicator() : SpinKitThreeBounce(
      color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.grey[800] : Colors.grey[200],
      size: 20,
    );
  }
}

class LoadingController {

  FlipCardController flipCardController = FlipCardController();

  bool isLoading = false;

  void start() {
    isLoading = true;
    flipCardController.toggleCard();
  }

  void end() {
    isLoading = false;
    flipCardController.toggleCard();
  }

  void toggle() {
    isLoading = !isLoading;
    flipCardController.toggleCard();
  }

}