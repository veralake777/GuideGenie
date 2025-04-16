import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }
  
  // Auth token management
  Future<void> saveAuthToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString(authTokenKey, token);
  }
  
  Future<String?> getAuthToken() async {
    final prefs = await _getPrefs();
    return prefs.getString(authTokenKey);
  }
  
  Future<void> deleteAuthToken() async {
    final prefs = await _getPrefs();
    await prefs.remove(authTokenKey);
  }
  
  // User ID management
  Future<void> saveUserId(String userId) async {
    final prefs = await _getPrefs();
    await prefs.setString(userIdKey, userId);
  }
  
  Future<String?> getUserId() async {
    final prefs = await _getPrefs();
    return prefs.getString(userIdKey);
  }
  
  // Theme management
  Future<void> saveThemeMode(String themeMode) async {
    final prefs = await _getPrefs();
    await prefs.setString(themeKey, themeMode);
  }
  
  Future<String?> getThemeMode() async {
    final prefs = await _getPrefs();
    return prefs.getString(themeKey);
  }
  
  // Generic methods for saving and retrieving objects
  Future<void> saveObject(String key, Map<String, dynamic> data) async {
    final prefs = await _getPrefs();
    
    // Convert each value to string before saving
    final stringMap = data.map((key, value) => MapEntry(key, value.toString()));
    await prefs.setStringList(key, [
      ...stringMap.entries.map((e) => '${e.key}:${e.value}'),
    ]);
  }
  
  Future<Map<String, String>?> getObject(String key) async {
    final prefs = await _getPrefs();
    final list = prefs.getStringList(key);
    
    if (list == null) return null;
    
    final map = <String, String>{};
    for (final item in list) {
      final parts = item.split(':');
      if (parts.length >= 2) {
        final itemKey = parts[0];
        final itemValue = parts.sublist(1).join(':');
        map[itemKey] = itemValue;
      }
    }
    
    return map;
  }
  
  // Clear all data
  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}
