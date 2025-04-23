import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/providers/game_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:guide_genie/services/firebase_service.dart';
import 'package:guide_genie/utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _errorMessage;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    print("SplashScreen: Starting service initialization");

    try {
      // First ensure Firebase is initialized
      print("SplashScreen: Checking Firebase initialization");
      if (!FirebaseService.instance.isInitialized) {
        print("SplashScreen: Firebase not initialized, initializing now");
        await FirebaseService.instance.initialize();
        print("SplashScreen: Firebase initialized successfully");
      } else {
        print("SplashScreen: Firebase already initialized");
      }
      
      // Then initialize providers in order
      print("SplashScreen: Getting GameProvider");
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      await gameProvider.initialize();
      
      print("SplashScreen: Getting PostProvider");
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      if (postProvider != null) {
        await postProvider.initialize();
        print("SplashScreen: PostProvider initialized successfully");
      }
      
      // Check auth status last (after all services are ready)
      print("SplashScreen: Getting AuthProvider");
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print("SplashScreen: Checking auth status");
      await authProvider.checkAuth();
      print("SplashScreen: Auth status checked successfully");
      
      if (!mounted) {
        print("SplashScreen: Widget not mounted, returning");
        return;
      };
      
      // Delay for splash screen effect
      print("SplashScreen: Delaying for splash screen effect");
      await Future.delayed(const Duration(seconds: 2));
      print("SplashScreen: Delay completed");
      
      if (!mounted) {
      print("SplashScreen: Not mounted after delay, stopping");
      return;
      } 
      
      print("SplashScreen: Setting state to not initializing");
      setState(() {
        _isInitializing = false;
      });
      
      // Navigate to home screen
      print("SplashScreen: Navigating to home screen");
      Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
      print("SplashScreen: Navigation completed");
    } catch (e) {
      print("ERROR IN SPLASH SCREEN: $e");
      print("Stack trace: ${StackTrace.current}");
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("SplashScreen: Building UI, error: $_errorMessage, initializing: $_isInitializing");
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstants.gamingDarkBlue, 
              AppConstants.gamingDarkPurple,
              AppConstants.gamingNeonPurple.withOpacity(0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background...
          
          // IMPORTANT: Add this at the top of your UI stack to ensure errors are visible
          if (_errorMessage != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: $_errorMessage',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            // Background grid pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage(
                        'assets/images/grid_pattern.png', // Replace with a local asset
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        AppConstants.gamingNeonPurple.withOpacity(0.7),
                        BlendMode.overlay,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App icon with neon glow
                  Container(
                    padding: const EdgeInsets.all(AppConstants.paddingL),
                    decoration: BoxDecoration(
                      color: AppConstants.gamingDarkBlue,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.primaryNeon.withOpacity(0.7),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: AppConstants.secondaryNeon.withOpacity(0.7),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(
                        color: AppConstants.primaryNeon.withOpacity(0.7),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.videogame_asset,
                      size: 100,
                      color: AppConstants.primaryNeon,
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.paddingXL),
                  
                  // App name with gaming font and neon glow
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontFamily: AppConstants.gamingFontFamily,
                      color: AppConstants.primaryNeon,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: AppConstants.primaryNeon,
                          blurRadius: 10,
                          offset: Offset(0, 0),
                        ),
                        Shadow(
                          color: AppConstants.primaryNeon,
                          blurRadius: 20,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.paddingM),
                  
                  // App tagline with secondary neon color
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingL,
                      vertical: AppConstants.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.gamingDarkBlue.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppConstants.secondaryNeon.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      AppConstants.appTagline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppConstants.gamingFontFamily,
                        color: Colors.white,
                        fontSize: AppConstants.fontSizeM,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                        shadows: [
                          Shadow(
                            color: AppConstants.secondaryNeon,
                            blurRadius: 10,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.paddingXL),
                  
                  // Show error message if there is one
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      margin: const EdgeInsets.all(AppConstants.paddingM),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Error: $_errorMessage',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppConstants.fontSizeS,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: AppConstants.paddingM),
                  
                  // Custom loading indicator with neon colors
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppConstants.accentNeon.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.accentNeon.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppConstants.accentNeon),
                      strokeWidth: 3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}