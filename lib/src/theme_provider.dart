import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  bool isDarkMode = false;

  ThemeData get currentTheme =>
      isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
