import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/providers/game_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:guide_genie/screens/home_screen.dart';
import 'package:guide_genie/screens/splash_screen.dart';
import 'package:guide_genie/screens/game_details_screen.dart';
import 'package:guide_genie/screens/post_details_screen.dart';
import 'package:guide_genie/screens/login_screen.dart';
import 'package:guide_genie/screens/register_screen.dart';
import 'package:guide_genie/screens/profile_screen.dart';
import 'package:guide_genie/screens/search_screen.dart';
import 'package:guide_genie/screens/create_post_screen.dart';
import 'package:guide_genie/utils/constants.dart';
import 'package:guide_genie/services/postgres_database.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Print environment variables for debugging
  print('Environment debug information:');
  print('DATABASE_URL from dotenv: ${dotenv.env['DATABASE_URL'] ?? 'Not set in dotenv'}');
  
  // Check for direct environment variables
  const pgUser = String.fromEnvironment('PGUSER');
  const pgPassword = String.fromEnvironment('PGPASSWORD');
  const pgHost = String.fromEnvironment('PGHOST');
  const pgDatabase = String.fromEnvironment('PGDATABASE');
  const pgPort = String.fromEnvironment('PGPORT');
  const databaseUrl = String.fromEnvironment('DATABASE_URL');
  
  print('PGUSER: ${pgUser.isEmpty ? 'Not set' : pgUser}');
  print('PGHOST: ${pgHost.isEmpty ? 'Not set' : pgHost}');
  print('PGDATABASE: ${pgDatabase.isEmpty ? 'Not set' : pgDatabase}');
  print('PGPORT: ${pgPort.isEmpty ? 'Not set' : pgPort}');
  print('DATABASE_URL direct: ${databaseUrl.isEmpty ? 'Not set' : databaseUrl}');
  
  // Initialize database
  bool useMockData = true; // Use mock data for now since we're focusing on UI
  
  final db = PostgresDatabase();
  try {
    if (!useMockData) {
      print('Initializing PostgreSQL database connection...');
      await db.connect();
      print('Connected to PostgreSQL database successfully');
      
      // Explicitly check database state
      final games = await db.getAllGames();
      print('Initial database check: Found ${games.length} games in the database');
      
      // Quick check of API service to get posts
      final users = await db.getAllUsers();
      print('Initial database check: Found ${users.length} users in the database');
    } else {
      print('Using mock data for development and prototyping');
      // We'll use the mock data providers instead
    }
  } catch (e) {
    print('Failed to connect to PostgreSQL database: $e');
    print('Stack trace: ${StackTrace.current}');
    print('Falling back to mock data for development');
    // We'll use the mock data providers
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppConstants.lightTheme,
        darkTheme: AppConstants.darkTheme,
        themeMode: ThemeMode.dark, // Default to dark theme for gaming aesthetics
        initialRoute: AppConstants.splashRoute,
        routes: {
          AppConstants.splashRoute: (context) => const SplashScreen(),
          AppConstants.homeRoute: (context) => const HomeScreen(),
          AppConstants.loginRoute: (context) => const LoginScreen(),
          AppConstants.registerRoute: (context) => const RegisterScreen(),
          AppConstants.profileRoute: (context) => const ProfileScreen(),
          AppConstants.searchRoute: (context) => const SearchScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == AppConstants.gameDetailsRoute) {
            // Extract gameId
            final args = settings.arguments as Map<String, dynamic>;
            final gameId = args['gameId'] as String;
            
            return MaterialPageRoute(
              builder: (context) => GameDetailsScreen(gameId: gameId),
            );
          }
          
          if (settings.name == AppConstants.postDetailsRoute) {
            // Extract postId
            final args = settings.arguments as Map<String, dynamic>;
            final postId = args['postId'] as String;
            
            return MaterialPageRoute(
              builder: (context) => PostDetailsScreen(postId: postId),
            );
          }
          
          if (settings.name == AppConstants.createPostRoute) {
            // Extract gameId (optional)
            final args = settings.arguments as Map<String, dynamic>?;
            final gameId = args?['gameId'] as String?;
            
            return MaterialPageRoute(
              builder: (context) => CreatePostScreen(gameId: gameId),
            );
          }
          
          return null;
        },
      ),
    );
  }
}