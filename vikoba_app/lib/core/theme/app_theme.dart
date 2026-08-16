import 'package:flutter/material.dart';

/// Vikoba visual design system.
///
/// Palette drawn from East African textile colourways (deep forest green,
/// true gold, clay), cream canvas, ink text. Typography: Fraunces serif is
/// reserved for hero numbers / screen titles only; everything functional
/// uses Work Sans for high legibility at small sizes.
///
/// [AppColors] keeps the legacy shorthand names (primary, secondary, danger,
/// background, surface, textPrimary, textSecondary) as aliases so call sites
/// read naturally, with the design-brief names alongside.
abstract final class AppColors {
  // Light-theme palette (the design brief).
  static const Color lightForest = Color(0xFF1F6650); // primary — trust, growth
  static const Color lightForestDeep = Color(0xFF123D30); // hero gradients
  static const Color lightForestLight = Color(0xFF3A8A6D); // gradient lighten
  static const Color lightGold = Color(0xFFE8A93A); // secondary — prosperity
  static const Color lightGoldSoft = Color(0xFFF6DFA8); // badges, icon chips
  static const Color lightGoldDeep = Color(0xFFCB8A24); // gold gradient end
  static const Color lightClay = Color(0xFFBE4F2E); // loans, attention
  static const Color lightCream = Color(0xFFFBF5E9); // background
  static const Color lightInk = Color(0xFF23302B); // primary text
  static const Color lightInkSoft = Color(0xFF5B6660); // secondary text
  static const Color lightSurface = Color(0xFFFFFFFF); // card surfaces
  static const Color lightLine = Color(0xFFE7DCC5); // borders, dividers
  static const Color lightStone = Color(0xFF4E9FA8); // chart teal

  // Dark-theme palette — tuned for contrast on deep green-black surfaces.
  static const Color darkBackground = Color(0xFF0D1A14);
  static const Color darkSurface = Color(0xFF17251F);
  static const Color darkInk = Color(0xFFF2EBDC);
  static const Color darkInkSoft = Color(0xFFA9B8AE);
  static const Color darkLine = Color(0xFF2B3C33);
  static const Color darkForest = Color(0xFF57A88C);
  static const Color darkForestDeep = Color(0xFF9CCFBA);
  static const Color darkForestLight = Color(0xFF6FBE9F);
  static const Color darkGold = Color(0xFFE3B05F);
  static const Color darkGoldSoft = Color(0xFF3D2F13);
  static const Color darkGoldDeep = Color(0xFFC99A3E);
  static const Color darkClay = Color(0xFFE07A52);
  static const Color darkStone = Color(0xFF6FB8C0);

  /// Switched by the theme controller before a rebuild; every palette getter
  /// resolves to the light or dark value accordingly.
  static bool isDark = false;

  static Color get forest => isDark ? darkForest : lightForest;
  static Color get forestDeep => isDark ? darkForestDeep : lightForestDeep;
  static Color get forestLight => isDark ? darkForestLight : lightForestLight;
  static Color get gold => isDark ? darkGold : lightGold;
  static Color get goldSoft => isDark ? darkGoldSoft : lightGoldSoft;
  static Color get goldDeep => isDark ? darkGoldDeep : lightGoldDeep;
  static Color get clay => isDark ? darkClay : lightClay;
  static Color get cream => isDark ? darkBackground : lightCream;
  static Color get ink => isDark ? darkInk : lightInk;
  static Color get inkSoft => isDark ? darkInkSoft : lightInkSoft;
  static Color get surface => isDark ? darkSurface : lightSurface;
  static Color get line => isDark ? darkLine : lightLine;
  static Color get stone => isDark ? darkStone : lightStone;

  // Legacy aliases (kept so existing screens read naturally).
  static Color get primary => forest;
  static Color get primaryDark => forestDeep;
  static Color get secondary => gold;
  static Color get danger => clay;
  static Color get background => cream;
  static Color get textPrimary => ink;
  static Color get textSecondary => inkSoft;

  /// Status semantics: colour first, words second.
  static Color get statusOk => forest; // on track
  static Color get statusPending => gold; // pending / awaiting
  static Color get statusAttention => clay; // overdue / rejected / alerts
}

/// Typography helpers. Both faces are variable fonts, so the desired weight
/// is passed through `FontVariation('wght')` rather than relying on
/// synthetic bolding. Fraunces additionally fixes `opsz` for a display cut.
abstract final class AppFonts {
  static const String _body = 'WorkSans';
  static const String _display = 'Fraunces';

  static String get bodyFamily => _body;
  static String get displayFamily => _display;

  static TextStyle body(double size, FontWeight weight, {Color? color}) =>
      TextStyle(
        fontFamily: _body,
        fontSize: size,
        fontWeight: weight,
        color: color,
        fontVariations: [FontVariation('wght', weight.value.toDouble())],
      );

  static TextStyle displayFont(double size, FontWeight weight,
          {Color? color}) =>
      TextStyle(
        fontFamily: _display,
        fontSize: size,
        fontWeight: weight,
        color: color,
        fontVariations: [
          const FontVariation('opsz', 72.0),
          FontVariation('wght', weight.value.toDouble()),
        ],
      );
}

class AppTheme {
  static ThemeData light() => _build(
        background: AppColors.lightCream,
        surface: AppColors.lightSurface,
        ink: AppColors.lightInk,
        inkSoft: AppColors.lightInkSoft,
        line: AppColors.lightLine,
        primary: AppColors.lightForest,
        primaryDeep: AppColors.lightForestDeep,
        goldSoft: AppColors.lightGoldSoft,
        clay: AppColors.lightClay,
      );

  static ThemeData dark() => _build(
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        ink: AppColors.darkInk,
        inkSoft: AppColors.darkInkSoft,
        line: AppColors.darkLine,
        primary: AppColors.darkForest,
        primaryDeep: AppColors.darkForestDeep,
        goldSoft: AppColors.darkGoldSoft,
        clay: AppColors.darkClay,
      );

  static ThemeData _build({
    required Color background,
    required Color surface,
    required Color ink,
    required Color inkSoft,
    required Color line,
    required Color primary,
    required Color primaryDeep,
    required Color goldSoft,
    required Color clay,
  }) {
    final colorScheme = ColorScheme(
      brightness:
          background.computeLuminance() < 0.3 ? Brightness.dark : Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: goldSoft,
      onPrimaryContainer: primaryDeep,
      secondary: primary,
      onSecondary: Colors.white,
      secondaryContainer: goldSoft,
      onSecondaryContainer: primaryDeep,
      error: clay,
      onError: Colors.white,
      surface: surface,
      onSurface: ink,
      outline: line,
      outlineVariant: line,
    );

    final textTheme = _textTheme();

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: AppFonts.bodyFamily,
      textTheme: textTheme,
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppFonts.body(19, FontWeight.w700, color: ink),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: line),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppFonts.body(15, FontWeight.w700, color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: clay,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(color: clay, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppFonts.body(15, FontWeight.w700, color: clay),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: AppFonts.body(14, FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.clay,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: const CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: AppFonts.body(14, FontWeight.w400, color: inkSoft),
        labelStyle: AppFonts.body(14, FontWeight.w500, color: inkSoft),
        helperStyle: AppFonts.body(12, FontWeight.w400, color: inkSoft),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: clay),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: goldSoft,
        side: BorderSide.none,
        labelStyle: AppFonts.body(12, FontWeight.w600, color: primaryDeep),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: line,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: line,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryDeep,
        contentTextStyle: AppFonts.body(14, FontWeight.w500, color: ink),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primary,
      ),
    );
  }

  static TextTheme _textTheme() {
    // Wrappers keep fontVariations aligned with the requested weight.
    TextStyle body(double size, FontWeight w, {Color? color}) =>
        AppFonts.body(size, w, color: color);
    TextStyle display(double size, FontWeight w, {Color? color}) =>
        AppFonts.displayFont(size, w, color: color);

    return TextTheme(
      displayLarge: display(57, FontWeight.w600),
      displayMedium: display(45, FontWeight.w600),
      displaySmall: display(36, FontWeight.w600),
      headlineLarge: display(32, FontWeight.w600),
      headlineMedium: display(28, FontWeight.w600),
      headlineSmall: display(24, FontWeight.w600),
      titleLarge: display(22, FontWeight.w700),
      titleMedium: body(16, FontWeight.w700),
      titleSmall: body(14, FontWeight.w600),
      bodyLarge: body(16, FontWeight.w400),
      bodyMedium: body(14, FontWeight.w400),
      bodySmall: body(12, FontWeight.w400),
      labelLarge: body(15, FontWeight.w700),
      labelMedium: body(12, FontWeight.w600),
      labelSmall: body(11, FontWeight.w600),
    );
  }
}
