import 'package:cyber_vpn/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_read(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _read(SharedPreferences prefs) {
    return switch (prefs.getString(AppConfig.prefsThemeMode)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    await _prefs.setString(AppConfig.prefsThemeMode, mode.name);
    emit(mode);
  }
}
