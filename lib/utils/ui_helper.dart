import 'package:flutter/material.dart';
import 'package:guide_genie/utils/constants.dart';

/// UI helper class that provides consistent styling methods across the app
class UIHelper {
  // Creates a standardized neon-style container for card elements
  static Widget neonContainer({
    required Widget child,
    Color backgroundColor = AppConstants.gamingDarkBlue,
    Color borderColor = AppConstants.primaryNeon,
    double borderWidth = 1.5,
    double borderRadius = AppConstants.borderRadiusL,
    double glowIntensity = 0.6,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppConstants.paddingM),
    EdgeInsetsGeometry margin = const EdgeInsets.all(0),
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(glowIntensity),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
  
  // Creates a gaming-styled gradient background
  static BoxDecoration gamingGradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppConstants.gamingDarkBlue, 
          AppConstants.gamingDarkPurple,
          AppConstants.gamingNeonPurple.withOpacity(0.7),
        ],
      ),
    );
  }
  
  // Creates a grid pattern overlay for backgrounds
  static Widget gridPatternOverlay({double opacity = 0.1}) {
    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const NetworkImage(
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
    );
  }
  
  // Creates a neon text style
  static TextStyle neonTextStyle({
    required Color color,
    double fontSize = AppConstants.fontSizeL,
    FontWeight fontWeight = FontWeight.bold,
    double letterSpacing = 1.2,
    bool addShadow = true,
  }) {
    return TextStyle(
      fontFamily: AppConstants.gamingFontFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      shadows: addShadow ? [
        Shadow(
          color: color.withOpacity(0.8),
          blurRadius: 8,
          offset: const Offset(0, 0),
        ),
        Shadow(
          color: color.withOpacity(0.5),
          blurRadius: 16,
          offset: const Offset(0, 0),
        ),
      ] : null,
    );
  }
  
  // Creates a custom progress indicator with neon effect
  static Widget gamingProgressIndicator({
    Color color = AppConstants.accentNeon,
    double size = 60,
    double strokeWidth = 3,
  }) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeWidth: strokeWidth,
      ),
    );
  }
  
  // Creates a custom button with neon styling
  static Widget neonButton({
    required String text,
    required VoidCallback onPressed,
    Color textColor = AppConstants.primaryNeon,
    Color borderColor = AppConstants.primaryNeon,
    Color backgroundColor = AppConstants.gamingDarkPurple,
    IconData? icon,
    double width = double.infinity,
    double height = 50,
    bool isOutlined = false,
  }) {
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: textColor,
            side: BorderSide(color: borderColor, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            elevation: 5,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            side: BorderSide(color: borderColor, width: 2),
          );
    
    return SizedBox(
      width: width,
      height: height,
      child: icon != null
          ? isOutlined
              ? OutlinedButton.icon(
                  icon: Icon(icon),
                  label: Text(text),
                  onPressed: onPressed,
                  style: buttonStyle,
                )
              : ElevatedButton.icon(
                  icon: Icon(icon),
                  label: Text(text),
                  onPressed: onPressed,
                  style: buttonStyle,
                )
          : isOutlined
              ? OutlinedButton(
                  onPressed: onPressed,
                  style: buttonStyle,
                  child: Text(text),
                )
              : ElevatedButton(
                  onPressed: onPressed,
                  style: buttonStyle,
                  child: Text(text),
                ),
    );
  }
  
  // Creates a custom card with gaming theme styling
  static Widget gamingCard({
    required Widget child,
    Color cardColor = AppConstants.gamingDarkBlue,
    Color borderColor = AppConstants.primaryNeon,
    VoidCallback? onTap,
    double elevation = 5,
    double borderRadius = AppConstants.borderRadiusL,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppConstants.paddingM),
    EdgeInsetsGeometry margin = const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
  }) {
    final content = Container(
      padding: padding,
      child: child,
    );
    
    return Card(
      margin: margin,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: borderColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      color: cardColor,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              child: content,
            )
          : content,
    );
  }
  
  // Creates a custom input field with gaming theme styling
  static Widget gamingInputField({
    required String hint,
    TextEditingController? controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconPressed,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    Color borderColor = AppConstants.primaryNeon,
    Color textColor = Colors.white,
    Color fillColor = AppConstants.gamingDarkBlue,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
        filled: true,
        fillColor: fillColor,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: borderColor) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, color: borderColor),
                onPressed: onSuffixIconPressed,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
          borderSide: BorderSide(color: borderColor.withOpacity(0.5), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
      ),
    );
  }
  
  // Creates a section title with gaming-inspired styling
  static Widget sectionTitle(
    String title, 
    BuildContext context, {
    VoidCallback? onSeeAllPressed,
    Color? textColor,
    double fontSize = AppConstants.fontSizeL,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingM, 
        AppConstants.paddingL,
        AppConstants.paddingM, 
        AppConstants.paddingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppConstants.primaryNeon,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryNeon.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.paddingS),
              Text(
                title,
                style: neonTextStyle(
                  color: textColor ?? AppConstants.primaryNeon,
                  fontSize: fontSize,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          if (onSeeAllPressed != null)
            TextButton(
              onPressed: onSeeAllPressed,
              child: const Text(
                'See All',
                style: TextStyle(
                  color: AppConstants.secondaryNeon,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // Creates a custom app bar with gaming theme styling
  static AppBar gamingAppBar({
    required String title,
    List<Widget>? actions,
    bool centerTitle = false,
    PreferredSizeWidget? bottom,
    bool automaticallyImplyLeading = true,
    Color backgroundColor = AppConstants.gamingDarkPurple,
    Color titleColor = AppConstants.primaryNeon,
  }) {
    return AppBar(
      title: Text(
        title,
        style: neonTextStyle(
          color: titleColor,
          fontSize: AppConstants.fontSizeL,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      elevation: 4,
      automaticallyImplyLeading: automaticallyImplyLeading,
      iconTheme: IconThemeData(
        color: titleColor,
      ),
      actions: actions,
      bottom: bottom,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstants.gamingDarkBlue,
              AppConstants.gamingDarkPurple,
            ],
          ),
        ),
      ),
    );
  }
  
  // Creates an empty state widget with gaming styling
  static Widget emptyState({
    required String message,
    required IconData icon,
    VoidCallback? onActionPressed,
    String? actionText,
  }) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingL),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppConstants.gamingDarkBlue,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
        border: Border.all(
          color: AppConstants.primaryNeon.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryNeon.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppConstants.primaryNeon.withOpacity(0.6),
          ),
          const SizedBox(height: AppConstants.paddingL),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: AppConstants.fontSizeM,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (onActionPressed != null && actionText != null) ...[
            const SizedBox(height: AppConstants.paddingL),
            neonButton(
              text: actionText,
              onPressed: onActionPressed,
              width: 200,
              height: 48,
              textColor: AppConstants.accentNeon,
              borderColor: AppConstants.accentNeon,
            ),
          ],
        ],
      ),
    );
  }
}