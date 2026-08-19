import 'package:flutter/material.dart';

abstract final class AppColors {
  static const mint = Color(0xFF2EE6B0);
  static const mintDim = Color(0xFF1AAF86);

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: mint,
    onPrimary: Color(0xFF04211A),
    secondary: Color(0xFF8B93A7),
    onSecondary: Color(0xFF0B0D12),
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF1A0505),
    surface: Color(0xFF12151C),
    onSurface: Color(0xFFF2F4F8),
    surfaceContainerHighest: Color(0xFF1B1F29),
    outline: Color(0x14FFFFFF),
  );

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: mintDim,
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF5C6478),
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF4F6FA),
    onSurface: Color(0xFF12141A),
    surfaceContainerHighest: Color(0xFFFFFFFF),
    outline: Color(0x14000000),
  );
}
