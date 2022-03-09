import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../rehmat.dart';

class AppTheme {

  static TextStyle get flexibleSpaceBarStyle => TextStyle(
    fontFamily: Fonts.feature,
    fontWeight: FontWeight.w500
  );

  static ThemeData get light => buildTheme(
    primary: AppColors.primaryLight,
    accent: AppColors.accentLight,
    splash: Palette.light.primaryContainer,
    background: Palette.light.background,
    appBarColor: Palette.light.background,
    navigationBarColor: Palette.light.background,
    brightness: Brightness.light,
    textColor: Palette.light.onBackground,
    iconColor: Palette.light.onBackground,
    cardColor: Palette.light.surfaceVariant
  );

  static ThemeData get dark => buildTheme(
    primary: AppColors.primaryDark,
    accent: AppColors.accentDark,
    splash: Palette.dark.primaryContainer,
    background: Palette.dark.background,
    appBarColor: Palette.dark.surface,
    navigationBarColor: Palette.dark.background,
    brightness: Brightness.dark,
    textColor: Palette.dark.onBackground,
    iconColor: Palette.dark.onBackground,
    cardColor: Palette.dark.surfaceVariant
  );

  static ThemeData buildTheme({
    required MaterialColor primary,
    required MaterialColor accent,
    required Color splash,
    required Color background,
    required Color appBarColor,
    required Color navigationBarColor,
    required Brightness brightness,
    required Color textColor,
    required Color iconColor,
    required Color cardColor,
  }) => ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: background,
    splashColor: splash,
    fontFamily: Fonts.feature,
    appBarTheme: AppBarTheme(
      color: appBarColor,
      elevation: 0.7,
      actionsIconTheme: IconThemeData(color: iconColor),
      iconTheme: IconThemeData(color: iconColor),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 22,
        fontFamily: Fonts.appBar,
        fontWeight: FontWeight.w600
      ),
      systemOverlayStyle: brightness == Brightness.light ? SystemUiOverlayStyle.light.copyWith(
        statusBarColor: background,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light
      ) : SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: background,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark
      ),
    ),
    canvasColor: background,
    popupMenuTheme: const PopupMenuThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      elevation: 1
    ),
    dialogTheme: DialogTheme(
      backgroundColor: brightness == Brightness.light ? Palette.light.surface : Palette.dark.surface,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontFamily: Fonts.feature,
        color: brightness == Brightness.light ? Palette.light.onSurface : Palette.dark.onSurface
      ),
      shape: RoundedRectangleBorder(
        borderRadius: Constants.borderRadius
      ),
      contentTextStyle: TextStyle(
        color: textColor
      ),
    ),
    tooltipTheme: const TooltipThemeData(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      preferBelow: true,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 13
        ),
        shape: RoundedRectangleBorder(
          borderRadius: Constants.borderRadius
        ),
        primary: textColor
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 15
        ),
        textStyle: TextStyle(
          fontSize: 15,
          fontFamily: Fonts.feature,
          fontWeight: FontWeight.w600
        ),
        onPrimary: splash
      )
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: Constants.borderRadius
      ),
    ),
    textTheme: TextTheme(
      headline1: TextStyle(
        color: textColor,
        fontFamily: Fonts.feature,
        fontSize: 70
      ),
      headline2: TextStyle(
        color: textColor,
        fontFamily: Fonts.feature,
      ),
      headline3: TextStyle(
        color: textColor,
        fontFamily: Fonts.feature,
      ),
      headline4: TextStyle(
        color: textColor,
        fontFamily: Fonts.feature,
      ),
      headline5: TextStyle(
        color: textColor,
        fontFamily: Fonts.feature,
      ),
      headline6: TextStyle(
        color: textColor,
        fontFamily: Fonts.body,
      ),
      button: TextStyle(
        color: textColor,
      )
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: brightness == Brightness.light ? Palette.light.primaryContainer : Palette.dark.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: Constants.borderRadius,
      ),
      splashColor: brightness == Brightness.light ? Palette.light.primary : Palette.dark.primary,
      enableFeedback: true,
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 0,
      shadowColor: HexColor.fromHex('#B5A9A1'),
      shape: RoundedRectangleBorder(
        borderRadius: Constants.borderRadius,
      )
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: navigationBarColor,
      elevation: 0,
      enableFeedback: true,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      selectedItemColor: textColor,
      unselectedItemColor: textColor.withOpacity(0.7)
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      labelStyle: TextStyle(
        color: textColor
      )
    ),
    snackBarTheme: SnackBarThemeData(
      actionTextColor: brightness == Brightness.light ? Colors.white : Colors.black,
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: primary,
      accentColor: accent,
      brightness: brightness,
      backgroundColor: background,
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: textColor),
  );

}