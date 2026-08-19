import 'package:cyber_vpn/core/theme/app_colors.dart';
import 'package:cyber_vpn/core/theme/app_radii.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static ThemeData dark() => _build(AppColors.dark, const Color(0xFF0B0D12));

  static ThemeData light() => _build(AppColors.light, const Color(0xFFF4F6FA));

  static ThemeData _build(ColorScheme scheme, Color scaffold) {
    final text = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: scheme.brightness).textTheme,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      dividerColor: scheme.outline,
    );
  }
}
