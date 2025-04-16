import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/providers/game_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:guide_genie/screens/splash_screen.dart';
import 'package:guide_genie/screens/home_screen.dart';
import 'package:guide_genie/screens/game_details_screen.dart';
import 'package:guide_genie/screens/post_details_screen.dart';
import 'package:guide_genie/screens/login_screen.dart';
import 'package:guide_genie/screens/register_screen.dart';
import 'package:guide_genie/screens/profile_screen.dart';
import 'package:guide_genie/screens/search_screen.dart';
import 'package:guide_genie/screens/create_post_screen.dart';
import 'package:guide_genie/utils/theme.dart';
import 'package:guide_genie/utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: const SplashScreen(),
            routes: {
              AppConstants.homeRoute: (context) => const HomeScreen(),
              AppConstants.loginRoute: (context) => const LoginScreen(),
              AppConstants.registerRoute: (context) => const RegisterScreen(),
              AppConstants.profileRoute: (context) => const ProfileScreen(),
              AppConstants.searchRoute: (context) => const SearchScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == AppConstants.gameDetailsRoute) {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => GameDetailsScreen(
                    gameId: args['gameId'],
                  ),
                );
              } else if (settings.name == AppConstants.postDetailsRoute) {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => PostDetailsScreen(
                    postId: args['postId'],
                  ),
                );
              } else if (settings.name == AppConstants.createPostRoute) {
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (context) => CreatePostScreen(
                    gameId: args?['gameId'],
                  ),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
