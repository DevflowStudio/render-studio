import 'package:flutter/material.dart';

class Alerts {

  static void snackbar(BuildContext context, {
    required String text,
    Animation<double>? animation,
    SnackBarAction? action,
    bool floating = true,
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
          ) : null,
          margin: margin ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          padding: padding,
          duration: duration ?? const Duration(seconds: 4),
          elevation: 1,
          onVisible: onVisible,
        )
      );
    } catch (e) {
      return;
    }
  }

}