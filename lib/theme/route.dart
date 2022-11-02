import 'package:universal_io/io.dart';
import 'package:flutter/cupertino.dart';
import 'package:animations/animations.dart';
// ignore: unused_import
import '../screens/web/screens.dart' as web;

class AppRouter<T> extends PageRouteBuilder<T> {

  final Widget page;
  final SharedAxisTransitionType transitionType;

  AppRouter({this.transitionType = SharedAxisTransitionType.horizontal, required this.page}) : super(
    pageBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) => page,
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) => SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: transitionType,
      child: child,
    )
  );

  static Future<T?> push<T extends Object?>(BuildContext context, {
    required Widget page
  }) {
    if (Platform.isIOS) return Navigator.of(context).push<T>(CupertinoPageRoute(builder: (context) => page,));
    else return Navigator.of(context).push<T>(AppRouter(page: page));
  }

  static Future<T?> replace<T extends Object?>(BuildContext context, {
    required Widget page
  }) {
    if (Platform.isIOS) return Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (context) => page,));
    else return Navigator.of(context).pushReplacement(AppRouter(page: page));
  }

  static Future<T?> removeAllAndPush<T extends Object?>(BuildContext context, {
    required Widget page
  }) {
    if (Platform.isIOS) return Navigator.of(context).pushAndRemoveUntil<T>(CupertinoPageRoute(builder: (context) => page), (route) => false);
    else return Navigator.of(context).pushAndRemoveUntil<T>(AppRouter(page: page), (route) => false);
  }

}