import 'package:flutter/material.dart';
import 'package:guide_genie/models/user.dart';
import 'package:guide_genie/services/api_service.dart';
import 'package:guide_genie/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  // Getters
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _currentUser != null;

  // Check if user is authenticated on app start
  Future<void> checkAuthentication() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get token from storage
      final storedToken = await _storageService.getAuthToken();
      
      if (storedToken != null) {
        _token = storedToken;
        
        // Fetch current user data
        final userData = await _apiService.getCurrentUser();
        _currentUser = User.fromJson(userData);
        
        _isLoading = false;
        notifyListeners();
      } else {
        // No token found, user is not logged in
        _token = null;
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      // Error occurred, consider user as not logged in
      _token = null;
      _currentUser = null;
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call login API
      final response = await _apiService.login(email, password);
      
      // Save token and user data
      _token = response['token'];
      _currentUser = User.fromJson(response['user']);
      
      // Store token locally
      await _storageService.saveAuthToken(_token!);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _token = null;
      _currentUser = null;
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register user
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call register API
      final response = await _apiService.register(username, email, password);
      
      // Save token and user data
      _token = response['token'];
      _currentUser = User.fromJson(response['user']);
      
      // Store token locally
      await _storageService.saveAuthToken(_token!);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _token = null;
      _currentUser = null;
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear token from storage
      await _storageService.deleteAuthToken();
      
      // Clear user data and token
      _token = null;
      _currentUser = null;
      _errorMessage = null;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? username,
    String? email,
    String? bio,
    String? avatarUrl,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create updated user object
      final updatedUser = _currentUser!.copyWith(
        username: username,
        email: email,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      
      // Call API to update user
      await _apiService.updateUser(updatedUser);
      
      // Update local user data
      _currentUser = updatedUser;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add game to favorites
  Future<bool> addGameToFavorites(String gameId) async {
    if (_currentUser == null) return false;

    try {
      // Create list with new game id
      final updatedFavorites = List<String>.from(_currentUser!.favoriteGames);
      
      // Add game if not already in favorites
      if (!updatedFavorites.contains(gameId)) {
        updatedFavorites.add(gameId);
        
        // Update user with new favorites
        final updatedUser = _currentUser!.copyWith(
          favoriteGames: updatedFavorites,
        );
        
        // Call API to update user
        await _apiService.updateUser(updatedUser);
        
        // Update local user data
        _currentUser = updatedUser;
        
        // Update local storage
        await _storageService.saveFavoriteGames(updatedFavorites);
        
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Remove game from favorites
  Future<bool> removeGameFromFavorites(String gameId) async {
    if (_currentUser == null) return false;

    try {
      // Create list without the game id
      final updatedFavorites = List<String>.from(_currentUser!.favoriteGames)
        ..remove(gameId);
      
      // Update user with new favorites
      final updatedUser = _currentUser!.copyWith(
        favoriteGames: updatedFavorites,
      );
      
      // Call API to update user
      await _apiService.updateUser(updatedUser);
      
      // Update local user data
      _currentUser = updatedUser;
      
      // Update local storage
      await _storageService.saveFavoriteGames(updatedFavorites);
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Check if a game is in favorites
  bool isGameFavorite(String gameId) {
    if (_currentUser == null) return false;
    return _currentUser!.favoriteGames.contains(gameId);
  }
}