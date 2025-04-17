import 'package:flutter/material.dart';

class AppConstants {
  // App info
  static const String appName = 'GuideGenie';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your ultimate game guide companion';
  
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String favoriteGamesKey = 'favorite_games';
  
  // Avatar sizes
  static const double avatarSizeXS = 24.0;
  static const double avatarSizeS = 32.0; 
  static const double avatarSizeM = 48.0;
  static const double avatarSizeL = 64.0;
  static const double avatarSizeXL = 96.0;
  
  // Guide types
  static const Map<String, String> guideTypeNames = {
    'strategy': 'Strategy',
    'tierList': 'Tier List',
    'loadout': 'Loadout',
    'metaAnalysis': 'Meta Analysis',
    'beginnerTips': 'Beginner Tips',
    'advancedTips': 'Advanced Tips',
    'patch': 'Patch Notes',
    'news': 'News',
    'other': 'Other',
  };
  
  static const Map<String, IconData> guideTypeIcons = {
    'strategy': Icons.psychology,
    'tierList': Icons.leaderboard,
    'loadout': Icons.inventory_2,
    'metaAnalysis': Icons.insights,
    'beginnerTips': Icons.school,
    'advancedTips': Icons.military_tech,
    'patch': Icons.new_releases,
    'news': Icons.newspaper,
    'other': Icons.article,
  };
  
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
  static const String createGameRoute = '/create_game';
  static const String settingsRoute = '/settings';
  static const String accountRoute = '/account';
  static const String bookmarksRoute = '/bookmarks';
  static const String allGamesRoute = '/all_games';
  static const String allGuidesRoute = '/all_guides';
  static const String guideDetailsRoute = '/guide_details';
  static const String apiTestRoute = '/api_test';
  
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
  
  // Gaming theme colors
  static const Color primaryNeon = Color(0xFF00FFFF); // Cyan neon
  static const Color secondaryNeon = Color(0xFFFF00FF); // Magenta neon
  static const Color accentNeon = Color(0xFF00FF00); // Green neon
  static const Color warningNeon = Color(0xFFFFFF00); // Yellow neon
  
  static const Color gamingDarkBlue = Color(0xFF0A1128);
  static const Color gamingDarkPurple = Color(0xFF240046);
  static const Color gamingNeonPurple = Color(0xFF9000FF);
  static const Color gamingNeonBlue = Color(0xFF2E00F8);
  
  // Gaming-inspired gradients
  static const Gradient neonGradient = LinearGradient(
    colors: [gamingNeonPurple, gamingNeonBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Font family for gaming aesthetics
  static const String gamingFontFamily = 'Audiowide';
  
  // Light theme (gaming-inspired)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: gamingNeonPurple,
      brightness: Brightness.light,
      primary: gamingNeonPurple,
      secondary: gamingNeonBlue,
      tertiary: primaryNeon,
    ),
    appBarTheme: AppBarTheme(
      elevation: 4,
      centerTitle: true,
      backgroundColor: gamingNeonPurple,
      foregroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        fontSize: fontSizeL,
        fontWeight: FontWeight.bold,
        fontFamily: gamingFontFamily,
        letterSpacing: 1.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: paddingL, vertical: paddingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusL),
          side: const BorderSide(color: primaryNeon, width: 2),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          fontFamily: gamingFontFamily,
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusL),
        side: BorderSide(color: gamingNeonPurple.withOpacity(0.3), width: 1),
      ),
      color: Colors.white,
      shadowColor: gamingNeonPurple.withOpacity(0.3),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusL),
        borderSide: const BorderSide(color: gamingNeonPurple, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusL),
        borderSide: BorderSide(color: gamingNeonPurple.withOpacity(0.6), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusL),
        borderSide: const BorderSide(color: primaryNeon, width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: paddingL,
        vertical: paddingM,
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: gamingDarkPurple,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusL),
        side: const BorderSide(color: primaryNeon, width: 1),
      ),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      elevation: 16,
      tileHeight: 60,
      backgroundColor: Colors.white,
      indicatorColor: gamingNeonPurple.withOpacity(0.2),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusM),
      ),
    ),
    scaffoldBackgroundColor: Colors.grey[100],
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: gamingFontFamily, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontFamily: gamingFontFamily, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontFamily: gamingFontFamily, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontFamily: gamingFontFamily, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontFamily: gamingFontFamily, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontFamily: gamingFontFamily, fontWeight: FontWeight.bold),
    ),
    dividerTheme: const DividerThemeData(
      color: gamingNeonPurple,
      thickness: 1,
      indent: 20,
      endIndent: 20,
    ),
  );
  
  // Dark theme (gaming-inspired)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: gamingNeonPurple,
      brightness: Brightness.dark,
      primary: primaryNeon,
      secondary: secondaryNeon,
      tertiary: accentNeon,
      background: gamingDarkBlue,
      surface: gamingDarkPurple,
    ),
    appBarTheme: AppBarTheme(
      elevation: 4,
      centerTitle: true,
      backgroundColor: gamingDarkPurple,
      foregroundColor: primaryNeon,
      titleTextStyle: const TextStyle(
        fontSize: fontSizeL,
        fontWeight: FontWeight.bold,
        color: primaryNeon,
        fontFamily: gamingFontFamily,
        letterSpacing: 1.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 8,
        backgroundColor: gamingDarkPurple,
        foregroundColor: primaryNeon,
        padding: const EdgeInsets.symmetric(horizontal: paddingL, vertical: paddingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusL),
          side: const BorderSide(color: primaryNeon, width: 2),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          fontFamily: gamingFontFamily,
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusL),
        side: const BorderSide(color: primaryNeon, width: 1),
      ),
      color: gamingDarkBlue,
      shadowColor: primaryNeon.withOpacity(0.3),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusL),
        borderSide: const BorderSide(color: primaryNeon, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusL),
        borderSide: BorderSide(color: primaryNeon.withOpacity(0.6), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusL),
        borderSide: const BorderSide(color: accentNeon, width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: paddingL,
        vertical: paddingM,
      ),
      filled: true,
      fillColor: gamingDarkBlue,
      labelStyle: TextStyle(color: primaryNeon.withOpacity(0.8)),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: gamingDarkPurple,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusL),
        side: const BorderSide(color: primaryNeon, width: 1),
      ),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      elevation: 16,
      tileHeight: 60,
      backgroundColor: gamingDarkBlue,
      indicatorColor: primaryNeon.withOpacity(0.2),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusM),
      ),
    ),
    scaffoldBackgroundColor: const Color(0xFF050A18), // Deep space blue
    textTheme: TextTheme(
      displayLarge: TextStyle(fontFamily: gamingFontFamily, fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: TextStyle(fontFamily: gamingFontFamily, fontWeight: FontWeight.bold, color: Colors.white),
      displaySmall: TextStyle(fontFamily: gamingFontFamily, fontWeight: FontWeight.bold, color: Colors.white),
      headlineLarge: TextStyle(fontFamily: gamingFontFamily, fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: TextStyle(fontFamily: gamingFontFamily, fontWeight: FontWeight.bold, color: Colors.white),
      titleLarge: TextStyle(fontFamily: gamingFontFamily, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white.withOpacity(0.9)),
      bodyMedium: TextStyle(color: Colors.white.withOpacity(0.8)),
    ),
    dividerTheme: const DividerThemeData(
      color: primaryNeon,
      thickness: 1,
      indent: 20,
      endIndent: 20,
    ),
  );
}