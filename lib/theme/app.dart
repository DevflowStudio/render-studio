import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import '../rehmat.dart';
import 'dart:math' as math;

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
    Color outline = brightness == Brightness.light ? HexColor.fromHex('#edf1f5') : HexColor.fromHex('#29303b');
    ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness).copyWith(
      primary: seed,
      primaryContainer: seed,
      onPrimaryContainer: HexColor.fromHex('#cad2fc'),
      background: background,
      surfaceVariant: surfaceVariant,
      outline: outline,
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
      tooltipTheme: TooltipThemeData(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        preferBelow: true,
        enableFeedback: true,
        decoration: BoxDecoration(
          color: colorScheme.onBackground,
          borderRadius: BorderRadius.circular(9),
        )
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
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelStyle: TextStyle(
          fontFamily: 'Inter'
        ),
        floatingLabelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
        ),
        enabledBorder: CustomOutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 1.5,
            color: brightness == Brightness.dark ? HexColor.fromHex('#636365') : HexColor.fromHex('#c4c4cc')
          ),
        ),
        focusedBorder: CustomOutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 2,
            color: brightness == Brightness.dark ? HexColor.fromHex('#636365') : HexColor.fromHex('#000000')
          ),
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

class CustomOutlineInputBorder extends InputBorder {
  /// Creates an underline border for an [InputDecorator].
  ///
  /// The [borderSide] parameter defaults to [BorderSide.none] (it must not be
  /// null). Applications typically do not specify a [borderSide] parameter
  /// because the input decorator substitutes its own, using [copyWith], based
  /// on the current theme and [InputDecorator.isFocused].
  ///
  /// The [borderRadius] parameter defaults to a value where the top left
  /// and right corners have a circular radius of 4.0. The [borderRadius]
  /// parameter must not be null.
  const CustomOutlineInputBorder({
    BorderSide borderSide = const BorderSide(),
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(4.0),
      topRight: Radius.circular(4.0),
      bottomLeft: Radius.circular(4.0),
      bottomRight: Radius.circular(4.0),
    ),
  })  : super(borderSide: borderSide);

  /// The radii of the border's rounded rectangle corners.
  ///
  /// When this border is used with a filled input decorator, see
  /// [InputDecoration.filled], the border radius defines the shape
  /// of the background fill as well as the bottom left and right
  /// edges of the underline itself.
  ///
  /// By default the top right and top left corners have a circular radius
  /// of 4.0.
  final BorderRadius borderRadius;

  @override
  bool get isOutline => false;

  @override
  CustomOutlineInputBorder copyWith(
      {BorderSide? borderSide, BorderRadius? borderRadius}) {
    return CustomOutlineInputBorder(
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.only(bottom: borderSide.width);
  }

  @override
  CustomOutlineInputBorder scale(double t) {
    return CustomOutlineInputBorder(borderSide: borderSide.scale(t));
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRect(Rect.fromLTWH(rect.left, rect.top, rect.width,
          math.max(0.0, rect.height - borderSide.width)));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is CustomOutlineInputBorder) {
      return CustomOutlineInputBorder(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        borderRadius: BorderRadius.lerp(a.borderRadius, borderRadius, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is CustomOutlineInputBorder) {
      return CustomOutlineInputBorder(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  /// Draw a horizontal line at the bottom of [rect].
  ///
  /// The [borderSide] defines the line's color and weight. The `textDirection`
  /// `gap` and `textDirection` parameters are ignored.
  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    final Paint paint = borderSide.toPaint();
    final RRect outer = borderRadius.toRRect(rect);
    final RRect center = outer.deflate(borderSide.width / 2.0);
    canvas.drawRRect(center, paint);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is InputBorder && other.borderSide == borderSide;
  }

  @override
  int get hashCode => borderSide.hashCode;
}