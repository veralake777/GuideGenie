// lib/utils/constants.dart

import 'package:flutter/material.dart';

class AppConstants {
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
  static const String guideDetailsRoute = '/guide';
  static const String profileRoute = '/profile';
  static const String searchRoute = '/search';
  static const String createPostRoute = '/create_post';
  static const String settingsRoute = '/settings';
  static const String accountRoute = '/account';
  static const String bookmarksRoute = '/bookmarks';
  static const String allGamesRoute = '/all_games';
  static const String allGuidesRoute = '/all_guides';
  static const String apiTestRoute = '/api_test';
  static const String gameFeedScreen = '/game_feed';

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

  // UI constants
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double borderRadiusM = 12.0;
  static const double borderRadiusL = 16.0;
  static const double fontSizeS = 14.0;
  static const double fontSizeM = 16.0;
  static const double fontSizeL = 20.0;
  static const double iconSizeM = 24.0;

  // Theme
  static const Color primaryColor = Color(0xFF00FFFF);
  static const Color secondaryColor = Color(0xFFFF00FF);
  static const Color backgroundDark = Color(0xFF050A18);
  static const String fontFamily = 'OpenSans';
} 
