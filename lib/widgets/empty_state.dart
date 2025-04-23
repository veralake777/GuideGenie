import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconSize = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Neon-styled icon
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            decoration: BoxDecoration(
              color: AppConstants.gamingDarkBlue.withOpacity(0.7),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryNeon.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
              border: Border.all(
                color: AppConstants.primaryNeon.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: AppConstants.primaryNeon,
            ),
          ),
          
          const SizedBox(height: AppConstants.paddingL),
          
          // Title with gaming font
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppConstants.gamingFontFamily,
              fontSize: AppConstants.fontSizeXL,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: AppConstants.primaryNeon.withOpacity(0.7),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.paddingM),
          
          // Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.fontSizeM,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
          
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppConstants.paddingXL),
            
            // Action button with neon styling
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.gamingDarkBlue,
                foregroundColor: AppConstants.primaryNeon,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingXL,
                  vertical: AppConstants.paddingM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
                  side: const BorderSide(
                    color: AppConstants.primaryNeon,
                    width: 2,
                  ),
                ),
                elevation: 8,
                shadowColor: AppConstants.primaryNeon.withOpacity(0.5),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontFamily: AppConstants.gamingFontFamily,
                  fontSize: AppConstants.fontSizeM,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}