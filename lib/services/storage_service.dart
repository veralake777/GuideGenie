import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guide_genie/utils/constants.dart';

class StorageService {
  // Authentication token
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<void> deleteAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
  }

  // User data
  Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(userData);
    await prefs.setString(AppConstants.userKey, jsonString);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(AppConstants.userKey);
    
    if (jsonString == null) {
      return null;
    }
    
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userKey);
  }

  // Theme preference
  Future<void> saveThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeKey, themeMode);
  }

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.themeKey);
  }

  // Favorite games
  Future<void> saveFavoriteGames(List<String> gameIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.favoriteGamesKey, gameIds);
  }

  Future<List<String>> getFavoriteGames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(AppConstants.favoriteGamesKey) ?? [];
  }

  // App settings
  Future<void> saveSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}