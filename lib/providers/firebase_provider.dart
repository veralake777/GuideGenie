import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guide_genie/models/user.dart' as app_models;
import 'package:guide_genie/services/firebase_service.dart';
import 'package:guide_genie/services/firestore_service.dart';

class FirebaseProvider extends ChangeNotifier {
  FirebaseService _firebaseService = FirebaseService.instance;
  FirestoreService _firestoreService = FirestoreService();
  
  firebase_auth.User? _authUser;
  app_models.User? _appUser;
  bool _isInitialized = false;
  bool _isLoading = false;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authUser != null;
  firebase_auth.User? get authUser => _authUser;
  app_models.User? get user => _appUser;

  // Initialize Firebase
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _setLoading(true);
      await _firebaseService.initialize();
      
      // Listen for auth state changes
      _firebaseService.auth.authStateChanges().listen(_onAuthStateChanged);
      
      _isInitialized = true;
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      debugPrint('Error initializing Firebase: $e');
      rethrow;
    }
  }

  // Auth state change handler
  Future<void> _onAuthStateChanged(firebase_auth.User? user) async {
    _authUser = user;
    
    if (user != null) {
      // Get or create app user
      final appUser = await _getOrCreateAppUser(user);
      _appUser = appUser;
    } else {
      _appUser = null;
    }
    
    notifyListeners();
  }

  // Get or create app user from auth user
  Future<app_models.User> _getOrCreateAppUser(firebase_auth.User authUser) async {
    try {
      // Try to find existing user by ID
      final existingUser = await _firestoreService.getUserById(authUser.uid);
      if (existingUser != null) return existingUser;
      
      // Create new user if not found
      final newUser = app_models.User(
        id: authUser.uid,
        username: authUser.displayName ?? 'User${authUser.uid.substring(0, 5)}',
        email: authUser.email ?? '',
        avatarUrl: authUser.photoURL,
        createdAt: DateTime.now(),
      );
      
      return await _firestoreService.createUser(newUser);
    } catch (e) {
      debugPrint('Error getting or creating app user: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      final googleProvider = firebase_auth.GoogleAuthProvider();
      await _firebaseService.auth.signInWithPopup(googleProvider);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _firebaseService.auth.signOut();
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  // Update loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}