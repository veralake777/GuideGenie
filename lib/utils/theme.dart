import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color primaryDarkColor = Color(0xFF3700B3);
  static const Color primaryLightColor = Color(0xFFBB86FC);
  
  // Secondary colors
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color secondaryDarkColor = Color(0xFF018786);
  static const Color secondaryLightColor = Color(0xFFCEFAF8);
  
  // Background colors
  static const Color lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color darkBackgroundColor = Color(0xFF121212);
  
  // Error colors
  static const Color errorColor = Color(0xFFB00020);
  static const Color darkErrorColor = Color(0xFFCF6679);
  
  // Text colors
  static const Color lightTextColor = Color(0xFF000000);
  static const Color darkTextColor = Color(0xFFFFFFFF);
  
  // Card colors
  static const Color lightCardColor = Color(0xFFFFFFFF);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  
  // Light theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryLightColor,
      secondary: secondaryColor,
      secondaryContainer: secondaryLightColor,
      surface: lightCardColor,
      background: lightBackgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: lightTextColor,
      onBackground: lightTextColor,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: lightCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryLightColor.withOpacity(0.2),
      disabledColor: Colors.grey.withOpacity(0.2),
      selectedColor: primaryColor,
      secondarySelectedColor: secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      labelStyle: const TextStyle(color: primaryColor),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      brightness: Brightness.light,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: Colors.grey,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 2.0, color: primaryColor),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.grey,
      thickness: 0.5,
      space: 1,
    ),
    iconTheme: const IconThemeData(
      color: primaryColor,
      size: 24,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: lightTextColor),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: lightTextColor),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: lightTextColor),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: lightTextColor),
      titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: lightTextColor),
      bodyLarge: TextStyle(fontSize: 16, color: lightTextColor),
      bodyMedium: TextStyle(fontSize: 14, color: lightTextColor),
      bodySmall: TextStyle(fontSize: 12, color: Colors.grey),
    ),
  );
  
  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryLightColor,
      primaryContainer: primaryDarkColor,
      secondary: secondaryColor,
      secondaryContainer: secondaryDarkColor,
      surface: darkCardColor,
      background: darkBackgroundColor,
      error: darkErrorColor,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: darkTextColor,
      onBackground: darkTextColor,
      onError: Colors.black,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryDarkColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: darkCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLightColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryLightColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: darkErrorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      fillColor: darkCardColor,
      filled: true,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryDarkColor.withOpacity(0.3),
      disabledColor: Colors.grey[800]!.withOpacity(0.3),
      selectedColor: primaryLightColor,
      secondarySelectedColor: secondaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      labelStyle: const TextStyle(color: Colors.white),
      secondaryLabelStyle: const TextStyle(color: Colors.black),
      brightness: Brightness.dark,
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: primaryLightColor,
      unselectedLabelColor: Colors.grey,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 2.0, color: primaryLightColor),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey[700]!,
      thickness: 0.5,
      space: 1,
    ),
    iconTheme: const IconThemeData(
      color: primaryLightColor,
      size: 24,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: darkTextColor),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkTextColor),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkTextColor),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: darkTextColor),
      titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: darkTextColor),
      bodyLarge: TextStyle(fontSize: 16, color: darkTextColor),
      bodyMedium: TextStyle(fontSize: 14, color: darkTextColor),
      bodySmall: TextStyle(fontSize: 12, color: Colors.grey),
    ),
  );
}
