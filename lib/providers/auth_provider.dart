import 'package:flutter/material.dart';
import 'package:guide_genie/models/user.dart';
import 'package:guide_genie/services/api_service_new.dart';
import 'package:guide_genie/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _user;
  bool get isAuthenticated => _user != null && _token != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Check if a post is bookmarked
  bool isPostBookmarked(String postId) {
    if (_user == null) return false;
    return _user!.bookmarkedPosts.contains(postId);
  }

  // Check if user is authenticated (on app start)
  Future<bool> checkAuth() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = await _storageService.getAuthToken();
      
      if (token != null) {
        _token = token;
        
        // Get user data
        final userData = await _apiService.getCurrentUser();
        _user = User.fromJson(userData);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.login(email, password);
      
      // Save token
      _token = result['token'] as String;
      await _storageService.saveAuthToken(_token!);
      
      // Save user data
      _user = User.fromJson(result['user'] as Map<String, dynamic>);
      await _storageService.saveUser(result['user'] as Map<String, dynamic>);
      
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

  // Register
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.register(username, email, password);
      
      // Save token
      _token = result['token'] as String;
      await _storageService.saveAuthToken(_token!);
      
      // Save user data
      _user = User.fromJson(result['user'] as Map<String, dynamic>);
      await _storageService.saveUser(result['user'] as Map<String, dynamic>);
      
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

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    await _storageService.deleteAuthToken();
    await _storageService.deleteUser();
    
    _user = null;
    _token = null;
    
    _isLoading = false;
    notifyListeners();
  }

  // Update user profile
  Future<bool> updateProfile({
    String? bio,
    String? avatarUrl,
  }) async {
    if (_user == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = _user!.copyWith(
        bio: bio,
        avatarUrl: avatarUrl,
      );
      
      await _apiService.updateUser(updatedUser.toJson());
      
      // Update local user data
      _user = updatedUser;
      await _storageService.saveUser(updatedUser.toJson());
      
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
    if (_user == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Update favorites list
      final favoriteGames = List<String>.from(_user!.favoriteGames);
      
      if (!favoriteGames.contains(gameId)) {
        favoriteGames.add(gameId);
      }
      
      final updatedUser = _user!.copyWith(
        favoriteGames: favoriteGames,
      );
      
      await _apiService.updateUser(updatedUser.toJson());
      
      // Update local user data
      _user = updatedUser;
      await _storageService.saveUser(updatedUser.toJson());
      
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

  // Remove game from favorites
  Future<bool> removeGameFromFavorites(String gameId) async {
    if (_user == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Update favorites list
      final favoriteGames = List<String>.from(_user!.favoriteGames);
      favoriteGames.remove(gameId);
      
      final updatedUser = _user!.copyWith(
        favoriteGames: favoriteGames,
      );
      
      await _apiService.updateUser(updatedUser.toJson());
      
      // Update local user data
      _user = updatedUser;
      await _storageService.saveUser(updatedUser.toJson());
      
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

  // Check if a game is in user's favorites
  bool isGameFavorite(String gameId) {
    if (_user == null) return false;
    return _user!.favoriteGames.contains(gameId);
  }
  
  // Add post to bookmarks
  Future<bool> addPostToBookmarks(String postId) async {
    if (_user == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Update bookmarks list
      final bookmarkedPosts = List<String>.from(_user!.bookmarkedPosts);
      
      if (!bookmarkedPosts.contains(postId)) {
        bookmarkedPosts.add(postId);
      }
      
      final updatedUser = _user!.copyWith(
        bookmarkedPosts: bookmarkedPosts,
      );
      
      await _apiService.updateUser(updatedUser.toJson());
      
      // Update local user data
      _user = updatedUser;
      await _storageService.saveUser(updatedUser.toJson());
      
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

  // Remove post from bookmarks
  Future<bool> removePostFromBookmarks(String postId) async {
    if (_user == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Update bookmarks list
      final bookmarkedPosts = List<String>.from(_user!.bookmarkedPosts);
      bookmarkedPosts.remove(postId);
      
      final updatedUser = _user!.copyWith(
        bookmarkedPosts: bookmarkedPosts,
      );
      
      await _apiService.updateUser(updatedUser.toJson());
      
      // Update local user data
      _user = updatedUser;
      await _storageService.saveUser(updatedUser.toJson());
      
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
  
  // Toggle bookmark status for a post
  Future<bool> togglePostBookmark(String postId) async {
    if (isPostBookmarked(postId)) {
      return removePostFromBookmarks(postId);
    } else {
      return addPostToBookmarks(postId);
    }
  }

  bool hasUpvotedPost(String id) {
    if (_user == null) return false;
    return _user!.upvotedPosts.contains(id);
  }

  bool hasDownvotedPost(String id) {
    if (_user == null) return false;
    return _user!.downvotedPosts.contains(id);
  }

  bool hasUpvotedComment(String id) {
    if (_user == null) return false;
    return _user!.upvotedComments.contains(id);
  }

  bool hasDownvotedComment(String id) {
    if (_user == null) return false;
    return _user!.downvotedComments.contains(id);
  }
}