import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

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
    // IMPORTANT: Don't check if Firebase is initialized - just trust that it is
    // Don't throw an exception if Firebase.apps.isEmpty - main.dart ensures it's initialized
    
    // Just initialize service instances
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
}