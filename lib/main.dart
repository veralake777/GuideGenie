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
  
  // Initialize PostgreSQL database connection
  final db = PostgresDatabase();
  try {
    await db.connect();
    print('Connected to PostgreSQL database successfully');
  } catch (e) {
    print('Failed to connect to PostgreSQL database: $e');
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
        themeMode: ThemeMode.system,
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