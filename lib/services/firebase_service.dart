import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseService {
  static FirebaseService? _instance;
  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;
  late FirebaseStorage _storage;
  bool _initialized = false;

  // Private constructor
  FirebaseService._();

  // Singleton pattern
  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  bool get isInitialized => _initialized;
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
  FirebaseStorage get storage => _storage;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Firebase configuration
      final firebaseOptions = FirebaseOptions(
        apiKey: dotenv.env['VITE_FIREBASE_API_KEY'] ?? '',
        appId: dotenv.env['VITE_FIREBASE_APP_ID'] ?? '',
        projectId: dotenv.env['VITE_FIREBASE_PROJECT_ID'] ?? '',
        messagingSenderId: '',  // Optional, can be added later if needed
        storageBucket: '${dotenv.env['VITE_FIREBASE_PROJECT_ID']}.appspot.com',
      );

      // Initialize Firebase
      await Firebase.initializeApp(
        options: firebaseOptions,
      );

      // Initialize services
      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
      _storage = FirebaseStorage.instance;

      _initialized = true;
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      rethrow;
    }
  }
}