import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/providers/game_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:guide_genie/screens/splash_screen.dart';
import 'package:guide_genie/utils/theme.dart';

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
      child: MaterialApp(
        title: 'Guide Genie',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
