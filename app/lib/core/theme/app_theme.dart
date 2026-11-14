import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

ThemeData buildCultivaTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: CultivaColors.teal,
    primary: CultivaColors.teal,
    secondary: CultivaColors.terracotta,
    surface: CultivaColors.paper,
    onSurface: CultivaColors.ink,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: CultivaColors.paper,
    appBarTheme: const AppBarTheme(
      backgroundColor: CultivaColors.tealDark,
      foregroundColor: Colors.white,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: CultivaColors.woodDark,
      indicatorColor: CultivaColors.terracotta,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? Colors.white
              : const Color(0xFFE9D7B5),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? Colors.white
              : const Color(0xFFE9D7B5),
        ),
      ),
    ),
  );
}
