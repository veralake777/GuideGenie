import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String authTokenKey = 'auth_token';
  static const String themeKey = 'app_theme';
  static const String onboardingKey = 'onboarding_completed';

  // Save authentication token
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(authTokenKey, token);
  }

  // Get authentication token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(authTokenKey);
  }

  // Delete authentication token (logout)
  Future<void> deleteAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(authTokenKey);
  }

  // Save theme preference
  Future<void> saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themeKey, isDarkMode);
  }

  // Get theme preference
  Future<bool?> getThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(themeKey);
  }

  // Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingKey, true);
  }

  // Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(onboardingKey) ?? false;
  }

  // Save favorite games
  Future<void> saveFavoriteGames(List<String> gameIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_games', gameIds);
  }

  // Get favorite games
  Future<List<String>> getFavoriteGames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorite_games') ?? [];
  }

  // Save recent searches
  Future<void> saveRecentSearches(List<String> searches) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', searches);
  }

  // Get recent searches
  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recent_searches') ?? [];
  }

  // Clear recent searches
  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
  }

  // Save last visited game
  Future<void> saveLastVisitedGame(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_visited_game', gameId);
  }

  // Get last visited game
  Future<String?> getLastVisitedGame() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_visited_game');
  }
}