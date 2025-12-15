// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:musicplayer_app/themes/dark_mode.dart';
import 'package:musicplayer_app/themes/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  // initially light
  ThemeData _themeData = darkMode;

  // get theme
  ThemeData get themeData => _themeData;

  // is dark mode
  bool get isDarkMode => _themeData == darkMode;

  // set theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    // update ui
    notifyListeners();
  }

  // toggle theme
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
