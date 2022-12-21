import 'package:flutter/material.dart';

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
    bool? confirm = await showModalBottomSheet(
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              SizedBox(height: 12,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        child: Text(cancelButtonText),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    SizedBox(width: 6,),
                    Expanded(
                      child: SecondaryButton(
                        child: Text(confirmButtonText),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    )
                  ].maybeReverse(isDestructive),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom + 12,
              )
            ],
          ),
        ),
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

  static Future<String?> modalInfoBuilder(BuildContext context, {
    required String title,
    required String message,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Label(
                  label: title,
                ),
              ),
              SizedBox(height: 12,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom + 12,
              )
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