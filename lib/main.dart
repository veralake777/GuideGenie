import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/providers/game_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/providers/firebase_provider.dart';
import 'package:guide_genie/screens/home_screen.dart';
import 'dart:io' show Platform;

Future<void> main() async {
// Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables first if using dotenv
    await dotenv.load(fileName: '.env');
    
    // IMPORTANT: Initialize Firebase Core first - platform specific
    if (Platform.isIOS) {
      // On iOS, just initialize with the default options from GoogleService-Info.plist
      await Firebase.initializeApp();
      print("Firebase Core initialized with default options for iOS");
    } else {
      // For Android or web, use the manual configuration
      final firebaseOptions = FirebaseOptions(
        apiKey: dotenv.env['VITE_FIREBASE_API_KEY'] ?? '',
        appId: dotenv.env['VITE_FIREBASE_APP_ID'] ?? '',
        projectId: dotenv.env['VITE_FIREBASE_PROJECT_ID'] ?? '',
        messagingSenderId: '',  // Optional
        storageBucket: '${dotenv.env['VITE_FIREBASE_PROJECT_ID']}.appspot.com',
      );
      await Firebase.initializeApp(options: firebaseOptions);
      print("Firebase Core initialized with manual options for Android/Web");
    }
    
    // Run the app AFTER Firebase is initialized
    runApp(MyApp());
  } catch (e) {
    print("ERROR INITIALIZING APP: $e");
    // Show error app
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Error initializing app: $e",
              style: TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
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
        title: 'Guide Genie',
        theme: ThemeData.dark(), // Use your app theme
        home: SplashScreen(),
        routes: {
          '/home': (context) => HomeScreen(),
          // Other Routes
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // REMOVED DUPLICATE FIREBASE INITIALIZATION CODE
      // Firebase is already initialized in main()
      
      // Get the GameProvider and initialize it
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      await gameProvider.initialize();
      
      // Initialize other providers if needed
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      await postProvider.initialize();
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // await authProvider.initialize();
      
      final firebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);
      await firebaseProvider.initialize();
      
      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (e) {
      print('Error initializing app: $e');
      // Show error UI
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access providers to check for errors
    final gameProvider = Provider.of<GameProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show your app logo here
            Image.asset('assets/images/logo.png', width: 150, height: 150),
            SizedBox(height: 24),
            if (gameProvider.errorMessage != null)
              Text(
                'Error: ${gameProvider.errorMessage}',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              )
            else
              CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Guide Genie',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}