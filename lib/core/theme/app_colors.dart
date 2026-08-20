import 'package:flutter/material.dart';

abstract final class AppColors {
  /// Cyber emerald — active / protected accent.
  static const emerald = Color(0xFF00E6A1);

  /// Slightly deeper emerald for light surfaces (contrast).
  static const emeraldDeep = Color(0xFF00B87A);

  static const inactiveOutline = Color(0xFF2A3441);
  static const inactiveOutlineLight = Color(0xFFC5CDD8);

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: emerald,
    onPrimary: Color(0xFF031510),
    secondary: Color(0xFF8B93A7),
    onSecondary: Color(0xFF0D1117),
    tertiary: Color(0xFF5C6B7A),
    onTertiary: Color(0xFFF2F4F8),
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF1A0505),
    surface: Color(0xFF0D1117),
    onSurface: Color(0xFFF2F4F8),
    surfaceContainerHighest: Color(0xFF131922),
    outline: Color(0xFF2A3441),
  );

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: emeraldDeep,
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF5C6478),
    onSecondary: Color(0xFFFFFFFF),
    tertiary: Color(0xFF7A8699),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF4F6FA),
    onSurface: Color(0xFF12141A),
    surfaceContainerHighest: Color(0xFFFFFFFF),
    outline: inactiveOutlineLight,
  );
}
