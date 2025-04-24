import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

void main() {
  runApp(FirebaseTestApp());
}

class FirebaseTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FutureBuilder(
            future: _initializeFirebase(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              
              if (snapshot.hasError) {
                return Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                );
              }
              
              return Text(
                'Firebase initialized successfully!\nApps: ${Firebase.apps.length}',
                style: TextStyle(color: Colors.green, fontSize: 18),
                textAlign: TextAlign.center,
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      if (Platform.isIOS) {
        print("Initializing Firebase for iOS");
        await Firebase.initializeApp();
      } else {
        print("Initializing Firebase for Android/Web");
        await Firebase.initializeApp();
      }
      print("Firebase initialized: ${Firebase.apps.length} app(s)");
      return;
    } catch (e) {
      print("Firebase initialization error: $e");
      throw e;
    }
  }
}