import 'package:flutter/material.dart';

class ThemeManager with ChangeNotifier {
  static ThemeMode _themeMode = ThemeMode.dark;

  static get themeMode => _themeMode;

  static bool themeIsDark() {
    return _themeMode == ThemeMode.dark;
  }

  static toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    // notifyListeners();
  }
}
