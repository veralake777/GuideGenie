import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guide Genie',
      theme: ThemeData(
        // Use dark theme as base
        brightness: Brightness.dark,
        
        // Discord-inspired blue as primary color
        primaryColor: const Color(0xFF5865F2),
        primarySwatch: MaterialColor(
          0xFF5865F2,
          <int, Color>{
            50: Color(0xFFECEFFE),
            100: Color(0xFFCED3FD),
            200: Color(0xFFAEB4FC),
            300: Color(0xFF8E96FA),
            400: Color(0xFF7580F9),
            500: Color(0xFF5865F2),
            600: Color(0xFF505DF1),
            700: Color(0xFF4753EF),
            800: Color(0xFF3D49EE),
            900: Color(0xFF2D37EC),
          },
        ),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF5865F2),
          secondary: const Color(0xFFFEB83D),
          surface: Colors.grey[900]!,
          background: const Color(0xFF181A1D),
          error: const Color(0xFFED4245),
        ),
        
        // Background color
        scaffoldBackgroundColor: const Color(0xFF181A1D),
        
        // Card and surface colors
        cardColor: Colors.grey[900],
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // App bar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF181A1D),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        
        // Text theme using system fonts
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Roboto',
        ),
        
        // Button themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5865F2),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF5865F2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF5865F2),
            side: const BorderSide(
              color: Color(0xFF5865F2),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        
        // Divider theme
        dividerTheme: DividerThemeData(
          color: Colors.grey[800],
          thickness: 1,
          space: 32,
        ),
        
        // Global border radius
        visualDensity: VisualDensity.adaptivePlatformDensity,
        
        // Icon theme
        iconTheme: IconThemeData(
          color: Colors.grey[400],
          size: 24,
        ),
      ),
      
      darkTheme: ThemeData(
        // Same as theme for now, but can be customized if needed
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF5865F2),
        primarySwatch: MaterialColor(
          0xFF5865F2,
          <int, Color>{
            50: Color(0xFFECEFFE),
            100: Color(0xFFCED3FD),
            200: Color(0xFFAEB4FC),
            300: Color(0xFF8E96FA),
            400: Color(0xFF7580F9),
            500: Color(0xFF5865F2),
            600: Color(0xFF505DF1),
            700: Color(0xFF4753EF),
            800: Color(0xFF3D49EE),
            900: Color(0xFF2D37EC),
          },
        ),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF5865F2),
          secondary: const Color(0xFFFEB83D),
          surface: Colors.grey[900]!,
          background: const Color(0xFF181A1D),
          error: const Color(0xFFED4245),
        ),
        scaffoldBackgroundColor: const Color(0xFF181A1D),
      ),
      
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}