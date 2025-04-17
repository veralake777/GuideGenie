import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/utils/constants.dart';
import 'package:guide_genie/utils/ui_helper.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthenticated = authProvider.isAuthenticated;
    final currentUser = authProvider.currentUser;

    return Drawer(
      child: Container(
        decoration: UIHelper.gamingGradientBackground(),
        child: Stack(
          children: [
            // Add grid pattern overlay
            UIHelper.gridPatternOverlay(opacity: 0.05),
            
            // Main content
            ListView(
              padding: EdgeInsets.zero,
              children: [
                // Create a custom drawer header with neon effects
                _buildDrawerHeader(context, isAuthenticated, currentUser),
                
                // Navigation items with enhanced styling
                const SizedBox(height: AppConstants.paddingM),
                
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: 'Home',
                  isSelected: true,
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
                  },
                ),
                
                _buildDrawerItem(
                  context,
                  icon: Icons.search,
                  title: 'Explore',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppConstants.searchRoute);
                  },
                ),
                
                _buildDrawerItem(
                  context,
                  icon: Icons.games,
                  title: 'All Games',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to games list screen
                    Navigator.pushNamed(context, AppConstants.allGamesRoute);
                  },
                ),
                
                _buildDrawerItem(
                  context,
                  icon: Icons.menu_book,
                  title: 'All Guides',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to guides list screen
                    Navigator.pushNamed(context, AppConstants.allGuidesRoute);
                  },
                ),
                
                if (isAuthenticated) ...[
                  _buildDrawerItem(
                    context,
                    icon: Icons.bookmark,
                    title: 'Bookmarks',
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to bookmarks screen
                      Navigator.pushNamed(context, AppConstants.bookmarksRoute);
                    },
                  ),
                ],
                
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.paddingS,
                    horizontal: AppConstants.paddingL,
                  ),
                  child: Divider(
                    color: AppConstants.primaryNeon.withOpacity(0.3),
                    thickness: 1,
                  ),
                ),
                
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppConstants.settingsRoute);
                  },
                ),
                
                _buildDrawerItem(
                  context,
                  icon: Icons.api,
                  title: 'API Test',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppConstants.apiTestRoute);
                  },
                ),
                
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    _showGamingAboutDialog(context);
                  },
                ),
                
                if (isAuthenticated) ...[
                  // Logged in state - Account and Logout options
                  _buildDrawerItem(
                    context,
                    icon: Icons.account_circle,
                    title: 'My Account',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppConstants.accountRoute);
                    },
                  ),
                  
                  _buildDrawerItem(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    isDestructive: true,
                    onTap: () async {
                      Navigator.pop(context);
                      await authProvider.logout();
                      Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
                    },
                  ),
                ] else ...[
                  // Not logged in state - Login and Register buttons with neon styling
                  const SizedBox(height: AppConstants.paddingL),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
                    child: UIHelper.neonButton(
                      text: 'Log In',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppConstants.loginRoute);
                      },
                      isOutlined: true,
                      textColor: AppConstants.primaryNeon,
                      borderColor: AppConstants.primaryNeon,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
                    child: UIHelper.neonButton(
                      text: 'Sign Up',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppConstants.registerRoute);
                      },
                      textColor: Colors.white,
                      borderColor: AppConstants.accentNeon,
                      backgroundColor: AppConstants.gamingDarkPurple,
                    ),
                  ),
                ],
                
                // Version footer
                const SizedBox(height: AppConstants.paddingXL),
                Center(
                  child: Text(
                    'v${AppConstants.appVersion}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Enhanced drawer header with neon effects
  Widget _buildDrawerHeader(BuildContext context, bool isAuthenticated, user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.gamingNeonPurple.withOpacity(0.7),
            AppConstants.gamingDarkPurple,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryNeon.withOpacity(0.2),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              // App logo with glow
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.gamingDarkBlue.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryNeon.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                  border: Border.all(
                    color: AppConstants.primaryNeon.withOpacity(0.7),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.videogame_asset,
                  color: AppConstants.primaryNeon,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // App name with neon text
              Text(
                AppConstants.appName,
                style: UIHelper.neonTextStyle(
                  color: AppConstants.primaryNeon,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // App tagline
          Text(
            AppConstants.appTagline,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontStyle: FontStyle.italic,
              shadows: [
                Shadow(
                  color: AppConstants.secondaryNeon.withOpacity(0.5),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          
          if (isAuthenticated && user != null) ...[
            const SizedBox(height: 16),
            // User profile section with neon border
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingS,
                vertical: AppConstants.paddingXS,
              ),
              decoration: BoxDecoration(
                color: AppConstants.gamingDarkBlue.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
                border: Border.all(
                  color: AppConstants.secondaryNeon.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Avatar with glow
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.secondaryNeon.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                          ? Text(
                              user.username.isNotEmpty
                                  ? user.username[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: AppConstants.gamingDarkPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Username
                  Expanded(
                    child: Text(
                      user.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Elite badge for returning users
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.accentNeon.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppConstants.accentNeon.withOpacity(0.6),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Elite',
                      style: TextStyle(
                        color: AppConstants.accentNeon,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  // Enhanced drawer item with neon effects
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Function onTap,
    bool isSelected = false,
    bool isDestructive = false,
  }) {
    final Color itemColor = isDestructive
        ? Colors.red.shade300
        : isSelected
            ? AppConstants.primaryNeon
            : Colors.white;
            
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingXS,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? AppConstants.primaryNeon.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
          border: isSelected
              ? Border.all(
                  color: AppConstants.primaryNeon.withOpacity(0.3),
                  width: 1,
                )
              : null,
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: itemColor,
            size: 22,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: itemColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
          onTap: () => onTap(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
          ),
          dense: true,
          visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
        ),
      ),
    );
  }
  
  // Custom gaming-styled about dialog
  void _showGamingAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: UIHelper.neonContainer(
          backgroundColor: AppConstants.gamingDarkBlue,
          padding: const EdgeInsets.all(AppConstants.paddingL),
          borderRadius: AppConstants.borderRadiusL,
          borderColor: AppConstants.primaryNeon,
          glowIntensity: 0.7,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(AppConstants.paddingS),
                decoration: BoxDecoration(
                  color: AppConstants.gamingDarkPurple.withOpacity(0.7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryNeon.withOpacity(0.5),
                      blurRadius: 15,
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
                  color: AppConstants.primaryNeon,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingM),
              
              // App name
              Text(
                AppConstants.appName,
                style: UIHelper.neonTextStyle(
                  color: AppConstants.primaryNeon,
                  fontSize: 28,
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingXS),
              
              // Version
              Text(
                'Version ${AppConstants.appVersion}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingL),
              
              // Description
              Text(
                'Your ultimate gaming companion, providing access to community-driven guides, tier lists, and strategies for your favorite games.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppConstants.paddingL),
              
              // Copyright
              Text(
                '© 2024 GuideGenie',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingL),
              
              // Close button
              UIHelper.neonButton(
                text: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                width: 120,
                height: 40,
                textColor: Colors.white,
                borderColor: AppConstants.secondaryNeon,
                backgroundColor: AppConstants.gamingDarkPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}