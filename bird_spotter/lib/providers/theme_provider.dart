import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  var backgroundGradient_1 = Color(0xFF90CAF9);
  var backgroundGradient_2 = Color(0x61FFFFFF);
  var accent = Color(0xFF2196F3);

  TextStyle heading = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  TextStyle body = TextStyle(fontSize: 16);
}
