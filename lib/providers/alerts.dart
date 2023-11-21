import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:universal_io/io.dart';

import '../rehmat.dart';

class Alerts {

  static void snackbar(BuildContext context, {
    required String text,
    Animation<double>? animation,
    SnackBarAction? action,
    bool floating = false,
    Color? backgroundColor,
    EdgeInsets? margin,
    EdgeInsets? padding,
    Duration? duration,
    Function()? onVisible,
  }) {
    ScaffoldMessengerState().removeCurrentSnackBar(reason: SnackBarClosedReason.remove);
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          animation: animation,
          action: action,
          behavior: floating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
          backgroundColor: backgroundColor,
          shape: floating ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7)
          ) : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0)
          ),
          margin: floating ? (margin ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 8)) : null,
          padding: padding ?? EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          duration: duration ?? const Duration(seconds: 4),
          elevation: 1,
          onVisible: onVisible,
        )
      );
    } catch (e, stacktrace) {
      analytics.logError(e, cause: 'snackbar failed', stacktrace: stacktrace);
      return;
    }
  }

  static Future<bool> showConfirmationDialog(BuildContext context, {
    required String title,
    required String message,
    String confirmButtonText = 'Confirm',
    String cancelButtonText = 'Cancel',
    bool isDestructive = false,
  }) async {
    bool? confirm;
    if (Platform.isAndroid) confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelButtonText)
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmButtonText),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? Colors.red : null
            ),
          )
        ].maybeReverse(isDestructive),
      ),
    ); else confirm = await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        insetAnimationCurve: Sprung(),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Geist'
          ),
        ),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text(cancelButtonText),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: Text(confirmButtonText),
            onPressed: () => Navigator.of(context).pop(true),
            isDestructiveAction: isDestructive,
          )
        ].maybeReverse(isDestructive),
      ),
    );
    return confirm ?? false;
  }

  static Future<dynamic> dialog(BuildContext context, {
    required String title,
    String? description,
    required List<Widget> actions
  }) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: description != null ? Text(description) : null,
        actions: actions,
      )
    );
  }

  static Future<void> toast({
    BuildContext? context
  }) async { }

  static Future<String?> optionsBuilder(BuildContext context, {
    String? title,
    required List<AlertOption> options
  }) async {
    return await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      // barrierColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Palette.of(context).surfaceVariant,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Palette.isDark(context) ? Colors.grey[800] : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 12),
              if (title != null) ... [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Label(
                    label: title
                  ),
                ),
                SizedBox(height: 12,),
              ],
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: options.length,
                itemBuilder: (context, index) => ListTile(
                  leading: options[index].icon != null ? Icon(options[index].icon) : null,
                  title: Text(options[index].title),
                  onTap: () {
                    Navigator.of(context).pop(options[index].id);
                  },
                ),
                separatorBuilder: (context, index) => Divider(
                  height: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> picker(BuildContext context, {
    required List<Widget> children,
    int initialIndex = 0,
    double itemExtent = 30,
    required ValueChanged<int> onSelectedItemChanged,
  }) => showModalBottomSheet(
    context: context,
    backgroundColor: Palette.of(context).background,
    elevation: 0,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: _SlideDownBar(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 17),
              child: FilledTonalIconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(RenderIcons.done)
              ),
            )
          ],
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height / 5,
            minHeight: MediaQuery.of(context).size.height * 0.2,
          ),
          child: CupertinoPicker(
            itemExtent: itemExtent,
            onSelectedItemChanged: onSelectedItemChanged,
            children: children,
            scrollController: FixedExtentScrollController(initialItem: initialIndex),
            magnification: 1.1,
            diameterRatio: 1.3,
            squeeze: 1,
          ),
        ),
      ],
    ),
  );

  static Future<String?> modalInfoBuilder(BuildContext context, {
    required String title,
    required String message,
  }) async {
    return await modal(
      context,
      title: title,
      childBuilder: (context, setState) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  static Future<T?> modal<T>(BuildContext context, {
    String? title,
    required Widget Function(BuildContext context, void Function(void Function()) setState) childBuilder,
    List<Widget>? actionButton
  }) async {
    return await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      // barrierColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: Palette.of(context).background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _SlideDownBar(),
                  ),
                  SizedBox(height: 12),
                  if (title != null || actionButton != null) ... [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          if (title != null) Label(
                            label: title,
                          ),
                          if (actionButton != null) ... [
                            Spacer(),
                            ...actionButton
                          ]
                        ],
                      ),
                    ),
                    SizedBox(height: 12,),
                  ],
                  childBuilder(context, setState),
                  SizedBox(
                    height: Constants.of(context).bottomPadding + MediaQuery.of(context).viewInsets.bottom,
                  )
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  static Future<void> showModal(BuildContext context, {
    required Widget child
  }) => Navigator.of(context).push(
    RenderModalRoute(
      builder: (context) => child,
      color: Palette.of(context).background.withOpacity(0.2),
    )
  );

}

class _SlideDownBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 5,
          decoration: BoxDecoration(
            color: Palette.of(context).outline,
            borderRadius: BorderRadius.circular(5),
          ),
        )
      ],
    );
  }
}

class AlertOption {

  final String title;
  final IconData? icon;
  final String id;

  AlertOption({
    required this.title,
    this.icon,
    required this.id,
  });

}

class RenderModalRoute extends PageRoute<void> {

  RenderModalRoute({
    required this.builder,
    RouteSettings? settings,
    this.color,
  }) : super(settings: settings);

  final WidgetBuilder builder;
  final Color? color;

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => color;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => kAnimationDuration;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final result = builder(context);
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(animation),
        child: result,
      ),
    );
  }

}