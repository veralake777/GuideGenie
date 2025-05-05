import 'package:flutter/material.dart';
import 'ui_constants.dart';
import 'constants.dart';

class ThemeBuilder {
  static ThemeData buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
        primary: AppConstants.primaryColor,
        secondary: AppConstants.secondaryColor,
      ),
      scaffoldBackgroundColor: Colors.grey[100],
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontSize: UIConstants.fontSizeL,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: AppConstants.fontFamily),
        bodyMedium: TextStyle(fontFamily: AppConstants.fontFamily),
      ),
    );
  }

  static ThemeData buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.dark,
        primary: AppConstants.primaryColor,
        secondary: AppConstants.secondaryColor,
        background: AppConstants.backgroundDark,
        surface: AppConstants.backgroundDark,
      ),
      scaffoldBackgroundColor: AppConstants.backgroundDark,
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.backgroundDark,
        foregroundColor: AppConstants.primaryColor,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontSize: UIConstants.fontSizeL,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: AppConstants.fontFamily, color: Colors.white),
        bodyMedium: TextStyle(fontFamily: AppConstants.fontFamily, color: Colors.white70),
      ),
    );
  }
}

ThemeData buildGamerTheme({required bool isDark}) {
  final base = isDark ? ThemeData.dark() : ThemeData.light();

  return base.copyWith(
    useMaterial3: true,
    scaffoldBackgroundColor: isDark ? const Color(0xFF0D0D0D) : Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      foregroundColor: isDark ? Colors.white : Colors.black,
      elevation: 1,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    ),
    cardColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
    dividerColor: isDark ? Colors.grey[700] : Colors.grey[300],
    textTheme: base.textTheme.copyWith(
      bodySmall: TextStyle(fontSize: 11, color: isDark ? Colors.grey[300] : Colors.grey[800]),
      bodyMedium: TextStyle(fontSize: 13, color: isDark ? Colors.grey[100] : Colors.black87),
      bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
    colorScheme: base.colorScheme.copyWith(
      primary: const Color(0xFF00FFCC),
      secondary: const Color(0xFF9966FF),
      error: Colors.redAccent,
      surface: isDark ? const Color(0xFF1C1C1C) : Colors.grey[100],
      background: isDark ? const Color(0xFF0D0D0D) : Colors.white,
    ),
    iconTheme: base.iconTheme.copyWith(
      color: isDark ? Colors.grey[400] : Colors.grey[800],
      size: 20,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: const Color(0xFF00FFCC),
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
