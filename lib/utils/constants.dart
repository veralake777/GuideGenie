import 'package:flutter/material.dart';

class AppConstants {
  // App info
  static const String appName = 'Guide Genie';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your ultimate game guide companion';
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String favoriteGamesKey = 'favorite_games';
  
  // Routes
  static const String splashRoute = '/';
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String gameDetailsRoute = '/game';
  static const String postDetailsRoute = '/post';
  static const String profileRoute = '/profile';
  static const String searchRoute = '/search';
  static const String createPostRoute = '/create_post';
  static const String settingsRoute = '/settings';
  
  // Padding
  static const double paddingXXS = 2.0;
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;
  
  // Border radius
  static const double borderRadiusXS = 4.0;
  static const double borderRadiusS = 8.0;
  static const double borderRadiusM = 12.0;
  static const double borderRadiusL = 16.0;
  static const double borderRadiusXL = 24.0;
  
  // Font sizes
  static const double fontSizeXS = 12.0;
  static const double fontSizeS = 14.0;
  static const double fontSizeM = 16.0;
  static const double fontSizeL = 20.0;
  static const double fontSizeXL = 24.0;
  static const double fontSizeXXL = 32.0;
  
  // Icon sizes
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
  
  // Animation durations
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  
  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        fontSize: fontSizeL,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusM),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusM),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: paddingM,
        vertical: paddingM,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusM),
      ),
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      elevation: 2,
      tileHeight: 56,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusM),
      ),
    ),
    scaffoldBackgroundColor: Colors.grey[50],
  );
  
  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.deepPurple[800],
      titleTextStyle: const TextStyle(
        fontSize: fontSizeL,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusM),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusM),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: paddingM,
        vertical: paddingM,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusM),
      ),
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      elevation: 2,
      tileHeight: 56,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusM),
      ),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
  );
}