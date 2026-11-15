import 'package:material_ui/material_ui.dart';

import 'text.dart';
import 'tokens.dart';

ThemeData buildCultivaTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: CultivaColors.teal,
    // tealDark keeps text buttons, field labels and links at >= 4.5:1 on paper.
    primary: CultivaColors.tealDark,
    secondary: CultivaColors.terracotta,
    surface: CultivaColors.paper,
    onSurface: CultivaColors.ink,
  );
  final text = buildTextTheme();
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: kBodyFont,
    textTheme: text,
    scaffoldBackgroundColor: CultivaColors.paper,
    appBarTheme: AppBarTheme(
      backgroundColor: CultivaColors.tealDark,
      foregroundColor: Colors.white,
      centerTitle: false,
      titleTextStyle: text.titleLarge!.copyWith(color: Colors.white),
    ),
  );
}
