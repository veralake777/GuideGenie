import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:guide_genie/firebase_options.dart';
import 'package:guide_genie/screens/auth/login_screen.dart';
import 'package:guide_genie/screens/auth/register_screen.dart';
import 'package:guide_genie/screens/create_post_screen.dart';
import 'package:guide_genie/screens/game_feed_screen.dart';
import 'package:guide_genie/screens/home_screen.dart';
import 'package:guide_genie/screens/splash_screen.dart';
import 'package:guide_genie/screens/post_details_screen.dart';
import 'package:provider/provider.dart';
import 'utils/theme_builder.dart';
import 'utils/constants.dart'; // (For appName)

import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/comment_provider.dart';
import 'providers/game_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeBuilder.buildLightTheme(),
        darkTheme: ThemeBuilder.buildDarkTheme(),
        themeMode: ThemeMode.system, // 🌗 Auto switch based on device settings
        initialRoute: AppConstants.splashRoute,
        routes: {
          // Define your app routes here
          AppConstants.splashRoute: (context) => const SplashScreen(),
          AppConstants.homeRoute: (context) => const HomeScreen(),
          AppConstants.loginRoute: (context) => const LoginScreen(),
          AppConstants.registerRoute: (context) => const RegisterScreen(),
          AppConstants.gameFeedScreen: (context) => const GameFeedScreen(),
          AppConstants.createPostRoute: (context) => const CreatePostScreen(),
          AppConstants.postDetailsRoute: (context) => const PostDetailsScreen(),
          // AppConstants.settingsRoute: (context) => const SettingsScreen(),
          // AppConstants.accountRoute: (context) => const AccountScreen(),
          // AppConstants.bookmarksRoute: (context) => const BookmarksScreen(),
          // AppConstants.allGamesRoute: (context) => const AllGamesScreen()
        },
      ),
    );
  }
}
