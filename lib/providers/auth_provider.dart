import 'package:flutter/material.dart';
import 'package:guide_genie/models/user.dart';
import 'package:guide_genie/services/api_service.dart';
import 'package:guide_genie/services/storage_service.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  User? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final token = await _storageService.getAuthToken();
      if (token != null) {
        final userData = await _apiService.getCurrentUser();
        _currentUser = User.fromJson(userData);
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Failed to initialize authentication';
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      await _storageService.saveAuthToken(response['token']);
      _currentUser = User.fromJson(response['user']);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.register(username, email, password);
      await _storageService.saveAuthToken(response['token']);
      _currentUser = User.fromJson(response['user']);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.deleteAuthToken();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Method to update user preferences, voting history, etc.
  Future<void> updateUserData(User updatedUser) async {
    try {
      await _apiService.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update user data';
      notifyListeners();
    }
  }

  // Check if user has upvoted a post
  bool hasUpvotedPost(String postId) {
    return _currentUser?.upvotedPosts.contains(postId) ?? false;
  }

  // Check if user has downvoted a post
  bool hasDownvotedPost(String postId) {
    return _currentUser?.downvotedPosts.contains(postId) ?? false;
  }

  // Check if user has upvoted a comment
  bool hasUpvotedComment(String commentId) {
    return _currentUser?.upvotedComments.contains(commentId) ?? false;
  }

  // Check if user has downvoted a comment
  bool hasDownvotedComment(String commentId) {
    return _currentUser?.downvotedComments.contains(commentId) ?? false;
  }
}
