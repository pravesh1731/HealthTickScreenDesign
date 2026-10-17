import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF2F2F2);
  static const surface = Color(0xFFFFFFFF);
  static const card = Color(0xFFE3E3E3);
  static const ink = Color(0xFF111111);
  static const muted = Color(0xFF6E6E6E);
  static const faint = Color(0xFFA8A8A8);
  static const border = Color(0xFFB9B9B9);

  static const healthGreen = Color(0xFF5DB37E);
  static const progressGreen = Color(0xFF94C9A4);
  static const checkGreen = Color(0xFF1FB37A);
  static const lockBlue = Color(0xFF2F7FE8);
  static const warning = Color(0xFFE2A93B);
  static const danger = Color(0xFFD9534F);

  static const road = Color(0xFFDADADA);
  static const nodeRing = Color(0xFFD4D4D4);
  static const checkpoint = Color(0xFF9A5A3C);

  /// Parses `#RRGGBB` from the backend; falls back instead of throwing so a
  /// typo in the config only affects a colour, not the screen.
  static Color fromHex(String hex, {Color fallback = card}) {
    final cleaned = hex.replaceFirst('#', '');
    final value = cleaned.length == 6 ? int.tryParse(cleaned, radix: 16) : null;
    return value == null ? fallback : Color(0xFF000000 | value);
  }
}
