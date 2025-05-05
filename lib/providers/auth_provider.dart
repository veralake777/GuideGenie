import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guide_genie/services/firebase_auth_service.dart';
import '../models/user.dart' as app_models;

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  app_models.User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  app_models.User? get currentUser => _user;

  Future<void> register(String email, String password, String username) async {
    _setLoading(true);
    try {
      final authUser = await _authService.registerUser(
        email: email,
        password: password,
        username: username,
      );
      if (authUser != null) {
        final userDoc = await _firestore.collection('users').doc(authUser.uid).get();
        _user = app_models.User.fromMap(userDoc.data()!);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final authUser = await _authService.loginUser(
        email: email,
        password: password,
      );
      if (authUser != null) {
        final userDoc = await _firestore.collection('users').doc(authUser.uid).get();
        if (userDoc.exists) {
          _user = app_models.User.fromMap(userDoc.data()!);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}