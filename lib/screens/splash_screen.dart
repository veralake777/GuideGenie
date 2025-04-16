import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuth();
    
    if (!mounted) return;
    
    // Delay for splash screen effect
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Navigate to home screen
    Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
  }

  @override
  Widget build(BuildContext context) {
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
            // Background grid pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://cdn.pixabay.com/photo/2018/03/18/15/26/technology-3237100_1280.jpg'
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
                  Text(
                    AppConstants.appName,
                    style: const TextStyle(
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
                    child: Text(
                      AppConstants.appTagline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                  
                  const SizedBox(height: AppConstants.paddingXXL),
                  
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