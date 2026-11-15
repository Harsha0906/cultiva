import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Pixel display face for headings, numbers, buttons and labels.
const kPixelFont = 'PixelifySans';

/// Readable body face for task names and longer text (scales with system text size).
const kBodyFont = 'Nunito';

TextTheme buildTextTheme() {
  const ink = CultivaColors.ink;
  TextStyle pixel(double size, FontWeight w) => TextStyle(
    fontFamily: kPixelFont,
    fontSize: size,
    fontWeight: w,
    color: ink,
    height: 1.15,
  );
  TextStyle body(double size, FontWeight w) => TextStyle(
    fontFamily: kBodyFont,
    fontSize: size,
    fontWeight: w,
    color: ink,
    height: 1.4,
  );
  return TextTheme(
    displaySmall: pixel(32, FontWeight.w600),
    headlineMedium: pixel(26, FontWeight.w600),
    headlineSmall: pixel(22, FontWeight.w600),
    titleLarge: pixel(20, FontWeight.w600),
    titleMedium: pixel(17, FontWeight.w600),
    titleSmall: pixel(15, FontWeight.w600),
    labelLarge: pixel(16, FontWeight.w600),
    labelMedium: pixel(14, FontWeight.w500),
    labelSmall: pixel(12, FontWeight.w500),
    bodyLarge: body(17, FontWeight.w600),
    bodyMedium: body(16, FontWeight.w500),
    bodySmall: body(13, FontWeight.w500).copyWith(color: CultivaColors.inkSoft),
  );
}
