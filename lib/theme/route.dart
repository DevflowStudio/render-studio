import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

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
  }) => Navigator.of(context).push<T>(AppRouter(page: page));

  static Future<T?> replace<T extends Object?>(BuildContext context, {
    required Widget page
  }) => Navigator.of(context).pushReplacement(AppRouter(page: page));

  static Future<T?> removeAllAndPush<T extends Object?>(BuildContext context, {
    required Widget page
  }) => Navigator.of(context).pushAndRemoveUntil<T>(AppRouter(page: page), (route) => false);

}