import 'package:flutter/material.dart';

import '../rehmat.dart';

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

  static Future<bool> showConfirmationDialog(BuildContext context, {
    required String title,
    required String description,
    String confirmButtonText = 'Confirm',
    String cancelButtonText = 'Cancel',
    bool isDestructive = false,
  }) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            child: Text(cancelButtonText),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(confirmButtonText),
            onPressed: () => Navigator.of(context).pop(true),
          )
        ],
      )
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