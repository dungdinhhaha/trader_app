import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF0084FF); // Messenger blue
  static const Color secondaryColor = Color(
    0xFF1A1A1A,
  ); // Dark shade for background

  // Background colors
  static const Color backgroundColor = Color(0xFF000000); // Black background
  static const Color surfaceColor = Color(
    0xFF121212,
  ); // Slightly lighter black for cards

  // Text colors
  static const Color textPrimaryColor = Colors.white;
  static const Color textSecondaryColor = Color(
    0xFFB0B0B0,
  ); // Light gray for secondary text

  // Accent colors
  static const Color successColor = Color(
    0xFF00C851,
  ); // Green for success/profit
  static const Color errorColor = Color(0xFFFF4444); // Red for errors/loss
  static const Color warningColor = Color(0xFFFFBB33); // Amber for warnings
  static const Color infoColor = Color(0xFF33B5E5); // Light blue for info

  // Get the theme data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
      ),
      cardTheme: const CardTheme(
        color: surfaceColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: secondaryColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(primaryColor),
          foregroundColor: MaterialStateProperty.all(textPrimaryColor),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(primaryColor),
          side: MaterialStateProperty.all(
            const BorderSide(color: primaryColor),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(primaryColor),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
      dialogTheme: const DialogTheme(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimaryColor),
        displayMedium: TextStyle(color: textPrimaryColor),
        displaySmall: TextStyle(color: textPrimaryColor),
        headlineLarge: TextStyle(color: textPrimaryColor),
        headlineMedium: TextStyle(color: textPrimaryColor),
        headlineSmall: TextStyle(color: textPrimaryColor),
        titleLarge: TextStyle(color: textPrimaryColor),
        titleMedium: TextStyle(color: textPrimaryColor),
        titleSmall: TextStyle(color: textPrimaryColor),
        bodyLarge: TextStyle(color: textPrimaryColor),
        bodyMedium: TextStyle(color: textPrimaryColor),
        bodySmall: TextStyle(color: textSecondaryColor),
        labelLarge: TextStyle(color: textPrimaryColor),
        labelMedium: TextStyle(color: textPrimaryColor),
        labelSmall: TextStyle(color: textSecondaryColor),
      ),
    );
  }
}
