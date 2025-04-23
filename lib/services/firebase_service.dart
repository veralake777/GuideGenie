import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;

class FirebaseService {
  static FirebaseService? _instance;
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  FirebaseStorage? _storage;
  bool _initialized = false;

  // Private constructor
  FirebaseService._();

  // Singleton pattern
  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  // Safely check initialization before providing access
  bool get isInitialized => _initialized;
  
  // Safer getters with initialization checks
  FirebaseFirestore get firestore {
    if (!_initialized) {
      throw Exception('FirebaseService not initialized. Call initialize() first.');
    }
    return _firestore!;
  }
  
  FirebaseAuth get auth {
    if (!_initialized) {
      throw Exception('FirebaseService not initialized. Call initialize() first.');
    }
    return _auth!;
  }
  
  FirebaseStorage get storage {
    if (!_initialized) {
      throw Exception('FirebaseService not initialized. Call initialize() first.');
    }
    return _storage!;
  }

Future<void> initialize() async {
  if (_initialized) return;
  try {
    // IMPORTANT: Do NOT initialize Firebase again - it's already done in main()
    // Just check if Firebase is initialized
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase.initializeApp() must be called in main() first');
    }
    // Initialize service instances
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
    _storage = FirebaseStorage.instance;
    _initialized = true;
    debugPrint('Firebase service instances initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Firebase services: $e');
    rethrow;
  }
}
  
  // Convenience method for checking if user is logged in
  bool isUserLoggedIn() {
    if (!_initialized) return false;
    return _auth?.currentUser != null;
  }
  
  // Convenience method for getting current user
  User? get currentUser {
    if (!_initialized) return null;
    return _auth?.currentUser;
  }
}