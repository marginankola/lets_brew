import 'package:flutter/material.dart';

class ThemeConstants {
  // App theme colors
  static const Color darkPurple = Color(0xFF231437);
  static const Color lightPurple = Color(0xFF6A4775);
  static const Color darkGrey = Color(0xFF121212);
  static const Color darkBackground = Color(0xFF080808);
  static const Color brown = Color(0xFF9A7258);
  static const Color lightBrown = Color(0xFFBFA08A);
  static const Color darkBrown = Color(0xFF4D3326);
  static const Color cream = Color(0xFFF5F5DC);
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color lightText = Color(0xFFF5F5F5);

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: darkPurple,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: darkPurple,
      secondary: brown,
      tertiary: lightPurple,
      surface: Color(0xFF161616),
      onSurface: lightText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: lightText,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: lightText,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: lightText,
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: lightText,
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: lightText,
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: lightText, fontSize: 16.0),
      bodyMedium: TextStyle(color: lightText, fontSize: 14.0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brown,
        foregroundColor: cream,
        elevation: 6,
        shadowColor: Colors.black45,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkGrey.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(color: lightPurple.withOpacity(0.3), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: const BorderSide(color: lightPurple, width: 2.0),
      ),
      labelStyle: TextStyle(color: lightBrown),
      hintStyle: TextStyle(color: lightText.withOpacity(0.5)),
    ),
    cardTheme: CardTheme(
      color: darkGrey.withOpacity(0.9),
      elevation: 6,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: lightPurple,
      selectionColor: lightPurple.withOpacity(0.3),
      selectionHandleColor: lightPurple,
    ),
    iconTheme: IconThemeData(color: lightBrown, size: 24),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkBackground,
      selectedItemColor: lightBrown,
      unselectedItemColor: lightBrown.withOpacity(0.5),
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(
      color: darkGrey.withOpacity(0.6),
      thickness: 1,
      space: 40,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: brown,
      circularTrackColor: darkGrey,
    ),
  );
}
