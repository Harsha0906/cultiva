import 'package:material_ui/material_ui.dart';

/// Cultiva colour tokens (see docs/01-design-spec.md §5).
abstract final class CultivaColors {
  static const teal = Color(0xFF2F8F8A);
  static const tealDark = Color(0xFF226B67);
  static const terracotta = Color(0xFFD0673F);
  static const terracottaDark = Color(0xFF8A3A20);
  static const wood = Color(0xFF9C6B3F);
  static const woodDark = Color(0xFF6B4426);
  static const paper = Color(0xFFF8EED6);
  static const paperDark = Color(0xFFF3E6C8);
  static const line = Color(0xFFC9B58E);
  static const ink = Color(0xFF3B2A1E);
  static const inkSoft = Color(0xFF7A6450);
  static const grass = Color(0xFF6DB356);
  static const gold = Color(0xFFF2C14E);
}

/// Spacing on a 4/8 rhythm.
abstract final class Space {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Minimum interactive size (Apple 44pt / Material 48dp — we use 48 on Android).
const double kMinTap = 48;
