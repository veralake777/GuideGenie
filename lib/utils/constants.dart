import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Guide Genie';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your gaming companion for tier lists, loadouts and strategies';
  
  // Routes
  static const String splashRoute = '/';
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String profileRoute = '/profile';
  static const String searchRoute = '/search';
  static const String settingsRoute = '/settings';
  static const String gameDetailsRoute = '/game';
  static const String postDetailsRoute = '/post';
  static const String createPostRoute = '/create-post';
  
  // API Endpoints
  static const String apiBaseUrl = 'https://api.guidegenie.com';
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String gamesEndpoint = '/games';
  static const String postsEndpoint = '/posts';
  static const String commentsEndpoint = '/comments';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
  static const String themeKey = 'app_theme';
  static const String favoriteGamesKey = 'favorite_games';
  
  // Dimensions
  static const double paddingXXS = 2.0;
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;
  
  static const double borderRadiusS = 4.0;
  static const double borderRadiusM = 8.0;
  static const double borderRadiusL = 12.0;
  static const double borderRadiusXL = 16.0;
  
  static const double iconSizeXS = 14.0;
  static const double iconSizeS = 18.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 36.0;
  static const double iconSizeXL = 48.0;
  
  static const double avatarSizeS = 24.0;
  static const double avatarSizeM = 40.0;
  static const double avatarSizeL = 64.0;
  static const double avatarSizeXL = 120.0;
  
  static const double fontSizeXS = 10.0;
  static const double fontSizeS = 12.0;
  static const double fontSizeM = 14.0;
  static const double fontSizeL = 18.0;
  static const double fontSizeXL = 24.0;
  static const double fontSizeXXL = 30.0;
  static const double fontSizeXXXL = 36.0;
  
  // Colors
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color primaryVariantColor = Color(0xFF3700B3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color secondaryVariantColor = Color(0xFF018786);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFB00020);
  
  static const Color darkPrimaryColor = Color(0xFFBB86FC);
  static const Color darkPrimaryVariantColor = Color(0xFF3700B3);
  static const Color darkSecondaryColor = Color(0xFF03DAC6);
  static const Color darkSecondaryVariantColor = Color(0xFF03DAC6);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkErrorColor = Color(0xFFCF6679);
  
  // Theme
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryVariantColor,
      secondary: secondaryColor,
      secondaryContainer: secondaryVariantColor,
      background: backgroundColor,
      error: errorColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusM),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
        ),
      ),
    ),
    fontFamily: 'Roboto',
  );
  
  static ThemeData darkTheme = ThemeData(
    primaryColor: darkPrimaryColor,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimaryColor,
      primaryContainer: darkPrimaryVariantColor,
      secondary: darkSecondaryColor,
      secondaryContainer: darkSecondaryVariantColor,
      background: darkBackgroundColor,
      error: darkErrorColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      foregroundColor: Colors.white,
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusM),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
        ),
      ),
    ),
    fontFamily: 'Roboto',
  );
  
  // Guide Type Icons and Names
  static const Map<String, IconData> guideTypeIcons = {
    'strategy': Icons.psychology,
    'tierList': Icons.list,
    'loadout': Icons.inventory,
    'beginnerTips': Icons.tips_and_updates,
    'advancedTips': Icons.star,
    'metaAnalysis': Icons.analytics,
    'update': Icons.update,
    'news': Icons.newspaper,
    'other': Icons.article,
  };
  
  static const Map<String, String> guideTypeNames = {
    'strategy': 'Strategy',
    'tierList': 'Tier List',
    'loadout': 'Loadout',
    'beginnerTips': 'Beginner Tips',
    'advancedTips': 'Advanced Tips',
    'metaAnalysis': 'Meta Analysis',
    'update': 'Update',
    'news': 'News',
    'other': 'Other',
  };
  
  // Mock Data
  static const List<String> supportedGames = [
    'Fortnite',
    'League of Legends',
    'Valorant',
    'Street Fighter',
    'Call of Duty',
    'Warzone',
    'Marvel Rivals',
  ];
}