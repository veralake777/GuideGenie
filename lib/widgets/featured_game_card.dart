import 'package:flutter/material.dart';
import '../models/game.dart';
import '../screens/game_details_screen.dart';
import '../utils/constants.dart';
import '../utils/ui_helper.dart';

class FeaturedGameCard extends StatelessWidget {
  final Game game;
  
  const FeaturedGameCard({
    Key? key,
    required this.game,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameDetailsScreen(gameId: game.id),
          ),
        );
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: AppConstants.paddingM),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
          boxShadow: [
            // Double shadow for neon effect
            BoxShadow(
              color: AppConstants.primaryNeon.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Card body
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  // Game image
                  _buildGameImage(),
                  
                  // Stylized overlay with gradient and pattern
                  _buildOverlay(),
                  
                  // Game info overlay
                  _buildGameInfo(context),
                  
                  // Feature badge
                  _buildFeatureBadge(),
                ],
              ),
            ),
            
            // Glow border
            Container(
              height: 170,
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
                border: Border.all(
                  color: AppConstants.primaryNeon.withOpacity(0.7),
                  width: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGameImage() {
    return Image.network(
      game.imageUrl,
      height: 170,
      width: 300,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 170,
          width: 300,
          color: AppConstants.gamingDarkBlue,
          child: Center(
            child: UIHelper.gamingProgressIndicator(
              size: 40,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 170,
          width: 300,
          color: AppConstants.gamingDarkBlue,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppConstants.primaryNeon.withOpacity(0.7),
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'Image not available',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildOverlay() {
    return Stack(
      children: [
        // Dark gradient overlay for better text visibility
        Container(
          height: 170,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstants.gamingDarkBlue.withOpacity(0.1),
                AppConstants.gamingDarkPurple.withOpacity(0.8),
              ],
            ),
          ),
        ),
        
        // Add subtle grid pattern
        Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: Container(
              decoration: BoxDecoration(
                backgroundBlendMode: BlendMode.overlay,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppConstants.primaryNeon.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildGameInfo(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppConstants.gamingDarkPurple.withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Game title with neon effect
            Text(
              game.title,
              style: UIHelper.neonTextStyle(
                color: Colors.white,
                fontSize: 18,
                addShadow: true,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Game genre and rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Genre pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryNeon.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppConstants.primaryNeon.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    game.genre,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Rating with star icon
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: AppConstants.accentNeon,
                      size: 16,
                      shadows: [
                        Shadow(
                          color: AppConstants.accentNeon.withOpacity(0.7),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      game.rating.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: AppConstants.accentNeon.withOpacity(0.7),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureBadge() {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: AppConstants.accentNeon.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppConstants.accentNeon.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: AppConstants.accentNeon.withOpacity(0.7),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: AppConstants.accentNeon,
              size: 12,
            ),
            SizedBox(width: 4),
            Text(
              'Featured',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}