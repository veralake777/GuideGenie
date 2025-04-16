import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GuideGenieApp());
}

class GuideGenieApp extends StatelessWidget {
  const GuideGenieApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guide Genie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Modern dark theme base
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F111A),
        primaryColor: const Color(0xFF5865F2), // Discord blue
        
        // Color scheme
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF5865F2),
          secondary: Color(0xFF5865F2),
          surface: Color(0xFF1A1C23),
          background: Color(0xFF0F111A),
          error: Color(0xFFED4245),
        ),
        
        // Text theme using Google Fonts Inter
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
        
        // Elevations and cards
        cardTheme: CardTheme(
          color: const Color(0xFF1A1C23),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color(0xFF272935),
              width: 1,
            ),
          ),
          elevation: 0,
        ),
        
        // App bar theme
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF161920),
          elevation: 1,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        
        // Tab bar theme
        tabBarTheme: const TabBarTheme(
          labelColor: Color(0xFF5865F2),
          unselectedLabelColor: Color(0xFF8E8E8E),
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFF5865F2),
                width: 2,
              ),
            ),
          ),
        ),
        
        // Button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5865F2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16, 
              vertical: 12,
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Input theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1C23),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFF272935),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFF272935),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFF5865F2),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}