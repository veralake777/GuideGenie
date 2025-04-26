import 'package:firebase_core/firebase_core.dart';
import 'package:guide_genie/screens/account_screen.dart';
import 'package:guide_genie/screens/all_games_screen.dart';
import 'package:guide_genie/screens/all_guides_screen.dart' show AllGuidesScreen;
import 'package:guide_genie/screens/api_test_screen.dart';
import 'package:guide_genie/screens/create_post_screen.dart';
import 'package:guide_genie/screens/game_screen.dart';
import 'package:guide_genie/screens/home_screen.dart';
import 'package:guide_genie/screens/login_screen.dart';
import 'package:guide_genie/screens/post_screen.dart';
import 'package:guide_genie/screens/profile_screen.dart';
import 'package:guide_genie/screens/register_screen.dart';
import 'package:guide_genie/screens/search_screen.dart';
import 'package:guide_genie/screens/settings_screen.dart';
import 'package:guide_genie/screens/bookmarks_screen.dart';
import 'package:guide_genie/utils/constants.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/providers/game_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/providers/firebase_provider.dart';
// import 'package:guide_genie/screens/home_screen.dart';
import 'package:guide_genie/screens/splash_screen.dart';
import 'dart:io' show Platform;

void main() {
  // Just ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables if using dotenv
  dotenv.load(fileName: '.env');
  
  // Run the app with Firebase initialization wrapper
  runApp(const FirebaseInitApp());
}

class FirebaseInitApp extends StatelessWidget {
  const FirebaseInitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize Firebase here
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        // Show loading while Firebase initializes
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // If there was an error initializing Firebase
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "FirebaseInitApp: Error initializing Firebase: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        // If Firebase initialized successfully, proceed with the app
        return const MyApp();
      },
    );
  }

  // Initialize Firebase based on platform
  Future<void> _initializeFirebase() async {
    // try {
    //   if (Platform.isIOS) {
    //     // On iOS, just initialize with the default options from GoogleService-Info.plist
    //     await Firebase.initializeApp();
    //     print("Firebase Core initialized with default options for iOS");
    //   } else {
    //     // For Android or web, use the manual configuration
    //     final firebaseOptions = FirebaseOptions(
    //       apiKey: dotenv.env['VITE_FIREBASE_API_KEY'] ?? '',
    //       appId: dotenv.env['VITE_FIREBASE_APP_ID'] ?? '',
    //       projectId: dotenv.env['VITE_FIREBASE_PROJECT_ID'] ?? '',
    //       messagingSenderId: '',  // Optional
    //       storageBucket: '${dotenv.env['VITE_FIREBASE_PROJECT_ID']}.appspot.com',
    //     );
    //     await Firebase.initializeApp(options: firebaseOptions);
    //     print("Firebase Core initialized with manual options for Android/Web");
    //   }
    // } catch (e) {
    //   print("ERROR INITIALIZING FIREBASE: $e");
    //   throw e; // Re-throw the error to be caught by the FutureBuilder
    // }
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase Core initialized with default options");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GameProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => PostProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => FirebaseProvider(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: ThemeData.dark(), // Use your app theme
        home: SplashScreen(),
        routes: {
          // '/': (context) => SplashScreen(),
          AppConstants.loginRoute: (context) => LoginScreen(),
          AppConstants.registerRoute: (context) => RegisterScreen(),
          AppConstants.homeRoute: (context) => HomeScreen(),
          // '/post': (context) => PostScreen(),
          // '/game': (context) => GameScreen(),
          // '/gameDetail': (context) => GameDetailScreen(),
          AppConstants.searchRoute: (context) => SearchScreen(),
          AppConstants.profileRoute: (context) => ProfileScreen(),
          AppConstants.settingsRoute: (context) => SettingsScreen(),
          // '/about': (context) => AboutScreen(),
          // '/contact': (context) => ContactScreen(),
          // '/terms': (context) => TermsScreen(),
          // '/privacy': (context) => PrivacyScreen(),
          // '/postDetail': (context) => PostDetailScreen(),
          AppConstants.createPostRoute: (context) => CreatePostScreen(),
          // '/editPost': (context) => EditPostScreen(),
          AppConstants.bookmarksRoute: (context) => BookmarksScreen(),
          AppConstants.apiTestRoute: (context) => ApiTestScreen(),
          AppConstants.accountRoute: (context) => AccountScreen(),
          AppConstants.allGamesRoute: (context) => AllGamesScreen(),
          AppConstants.allGuidesRoute: (context) => AllGuidesScreen()
        },
      ),
    );
  }
}
