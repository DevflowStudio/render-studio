import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import '../rehmat.dart';

class AppTheme {

  static ThemeData build({
    required Brightness brightness,
    Color? seed
  }) {
    seed ??= HexColor.fromHex('#1437f6');
    Color contrastTextColor = brightness == Brightness.light ? Colors.black : Colors.white;
    Color contrastTextColorLight = brightness == Brightness.light ? Colors.grey[700]! : Colors.grey[200]!;
    Color background = brightness == Brightness.light ? HexColor.fromHex('#ffffff') : HexColor.fromHex('#0b0d0f');
    Color surfaceVariant = brightness == Brightness.light ? HexColor.fromHex('#f6f8fa') : HexColor.fromHex('#161a20');
    ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness).copyWith(
      primary: seed,
      primaryContainer: seed,
      onPrimaryContainer: HexColor.fromHex('#cad2fc'),
      background: background,
      surfaceVariant: surfaceVariant,
      outline: surfaceVariant,
      surface: brightness == Brightness.light ? HexColor.fromHex('#ffffff') : HexColor.fromHex('#131417')
    );
    return ThemeData(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Google Sans',
      colorScheme: colorScheme,
      useMaterial3: true,
      backgroundColor: background,
      scaffoldBackgroundColor: background,
      drawerTheme: DrawerThemeData(
        backgroundColor: brightness == Brightness.light ? HexColor.fromHex('#f6f8fa') : HexColor.fromHex('#131417')
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: background,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          color: colorScheme.onBackground
        ),
        surfaceTintColor: colorScheme.surfaceVariant
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          side: BorderSide(
            color: colorScheme.onSurfaceVariant.withOpacity(0.2),
            width: 0
          )
        ),
        textStyle: TextStyle(
          fontFamily: 'Google Sans',
          letterSpacing: 1,
          color: colorScheme.onSurfaceVariant
        ),
        color: colorScheme.surfaceVariant,
        enableFeedback: true,
        elevation: 1
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: Constants.borderRadius
        ),
        actionsPadding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          color: contrastTextColor
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Google Sans',
          fontSize: 16,
          color: contrastTextColorLight
        )
      ),
      tooltipTheme: const TooltipThemeData(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        preferBelow: true,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          enableFeedback: true,
          backgroundColor: surfaceVariant,
          padding: EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 18
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius)
          ),
          textStyle: TextStyle(
            fontSize: 17,
            fontFamily: 'Google Sans',
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          enableFeedback: true,
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius)
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 18
          ),
          textStyle: TextStyle(
            fontSize: 17,
            fontFamily: 'Google Sans',
            fontWeight: FontWeight.w500
          ),
        )
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius)
        ),
      ),
      listTileTheme: ListTileThemeData(
        // tileColor: surfaceVariant,
        horizontalTitleGap: 12,
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(30),
        // ),
        minLeadingWidth: 12,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Inter',
          color: contrastTextColor
        ),
        displayMedium: TextStyle(
          fontFamily: 'Inter',
          color: contrastTextColor
        ),
        displaySmall: TextStyle(
          fontFamily: 'Inter',
          color: contrastTextColor
        ),
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          color: contrastTextColor
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          color: contrastTextColor
        ),
        titleSmall: TextStyle(
          fontFamily: 'Inter',
          color: contrastTextColor
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Inter',
          color: contrastTextColor
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Inter',
          color: contrastTextColor
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Inter',
          color: contrastTextColorLight
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Google Sans',
          color: contrastTextColor
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Google Sans',
          color: contrastTextColor
        ),
        bodySmall: TextStyle(
          fontFamily: 'Google Sans',
          color: contrastTextColorLight
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        linearMinHeight: 4,
        color: contrastTextColorLight,
        linearTrackColor: contrastTextColorLight.withOpacity(0.05)
      ),
      cardTheme: CardTheme(
        color: surfaceVariant,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius)
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0.5,
        enableFeedback: true,
        showSelectedLabels: true,
        showUnselectedLabels: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: background,
        indicatorColor: surfaceVariant,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        border: UnderlineInputBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          )
        ),
        hintStyle: TextStyle(
          fontFamily: 'Google Sans'
        ),
      ),
      dividerTheme: DividerThemeData(
        endIndent: 18,
        indent: 18,
        color: brightness == Brightness.light ? HexColor.fromHex('#e1e0e3') : HexColor.fromHex('#374049')
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
      ),
      sliderTheme: SliderThemeData(
        showValueIndicator: ShowValueIndicator.always,
        trackHeight: 1,
        activeTrackColor: colorScheme.onBackground,
        thumbColor: colorScheme.onSurfaceVariant,
        trackShape: RoundedRectSliderTrackShape(),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder()
        }
      )
    );
  }

}