import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lets_brew/constants/theme_constants.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  final String _themePreferenceKey = 'isDarkMode';

  ThemeProvider() {
    _loadThemePreference();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme =>
      _isDarkMode
          ? ThemeConstants.darkTheme
          : ThemeData.light().copyWith(
            primaryColor: ThemeConstants.lightPurple,
            scaffoldBackgroundColor: Colors.grey[100],
            colorScheme: const ColorScheme.light(
              primary: ThemeConstants.lightPurple,
              secondary: ThemeConstants.brown,
              tertiary: ThemeConstants.darkPurple,
            ),
          );

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemePreference();
    notifyListeners();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themePreferenceKey) ?? true;
      notifyListeners();
    } catch (e) {
      print('Error loading theme preference: $e');
    }
  }

  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePreferenceKey, _isDarkMode);
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }
}
