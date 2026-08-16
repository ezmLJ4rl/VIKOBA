import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

/// Persisted light/dark theme selection.
///
/// The palette (see [AppColors]) is theme-aware: before a rebuild the
/// controller flips [AppColors.isDark] so every screen's hardcoded colours
/// resolve to the matching palette, and [ThemeMode] picks the ThemeData.
class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'vikoba.theme.mode';

  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    _mode = raw == 'dark' ? ThemeMode.dark : ThemeMode.light;
    AppColors.isDark = isDark;
    notifyListeners();
  }

  Future<void> setDark(bool dark) async {
    _mode = dark ? ThemeMode.dark : ThemeMode.light;
    AppColors.isDark = isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, isDark ? 'dark' : 'light');
  }
}
