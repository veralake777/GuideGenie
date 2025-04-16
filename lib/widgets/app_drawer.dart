import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/utils/constants.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isAuthenticated;
    final user = authProvider.currentUser;
    
    return Drawer(
      elevation: 16.0,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(context, isLoggedIn, user),
            _buildDrawerItems(context, isLoggedIn),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, bool isLoggedIn, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App icon and name
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.videogame_asset,
                  size: AppConstants.iconSizeL,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Text(
                AppConstants.appName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: AppConstants.fontSizeL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingL),
          // User info (if logged in) or login prompt
          if (isLoggedIn && user != null) ...[
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: user.avatarUrl != null 
                      ? NetworkImage(user.avatarUrl!) 
                      : null,
                  backgroundColor: Colors.white,
                  radius: 24,
                  child: user.avatarUrl == null
                      ? Text(
                          user.username[0].toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: AppConstants.fontSizeL,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.username,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: AppConstants.fontSizeM,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                          fontSize: AppConstants.fontSizeS,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Close drawer
                Navigator.pushNamed(context, AppConstants.loginRoute);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingL,
                  vertical: AppConstants.paddingM,
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.login),
              label: const Text(
                'Login / Register',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawerItems(BuildContext context, bool isLoggedIn) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
        children: [
          // Home
          _buildDrawerTile(
            context: context,
            icon: Icons.home,
            title: 'Home',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppConstants.homeRoute,
                (route) => false,
              );
            },
          ),
          // Search
          _buildDrawerTile(
            context: context,
            icon: Icons.search,
            title: 'Search Games & Guides',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.searchRoute);
            },
          ),
          // Browse Games
          _buildDrawerTile(
            context: context,
            icon: Icons.videogame_asset,
            title: 'Browse All Games',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to games list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!'))
              );
            },
          ),
          // Guide Categories
          _buildDrawerTile(
            context: context,
            icon: Icons.category,
            title: 'Guide Categories',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to categories
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!'))
              );
            },
          ),
          // Divider between common and user-specific options
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.paddingL,
              vertical: AppConstants.paddingS,
            ),
            child: Divider(height: 1),
          ),
          
          // User Account Section Header
          Padding(
            padding: const EdgeInsets.only(
              left: AppConstants.paddingL, 
              top: AppConstants.paddingM, 
              bottom: AppConstants.paddingS
            ),
            child: Text(
              'MY ACCOUNT',
              style: TextStyle(
                fontSize: AppConstants.fontSizeXS,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          
          // User-specific options
          if (isLoggedIn) ...[
            // Profile
            _buildDrawerTile(
              context: context,
              icon: Icons.person,
              title: 'My Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppConstants.profileRoute);
              },
            ),
            // My Guides
            _buildDrawerTile(
              context: context,
              icon: Icons.book,
              title: 'My Guides',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to user's guides
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!'))
                );
              },
            ),
            // Favorites
            _buildDrawerTile(
              context: context,
              icon: Icons.favorite,
              title: 'Favorites',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to favorites
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!'))
                );
              },
            ),
            // Create Guide
            _buildDrawerTile(
              context: context,
              icon: Icons.add_circle,
              title: 'Create Guide',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppConstants.createPostRoute);
              },
              isHighlighted: true,
            ),
            // Logout
            _buildDrawerTile(
              context: context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                authProvider.logout();
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppConstants.homeRoute,
                  (route) => false,
                );
              },
            ),
          ] else ...[
            // Login/Register when not logged in
            _buildDrawerTile(
              context: context,
              icon: Icons.login,
              title: 'Log In',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppConstants.loginRoute);
              },
            ),
            _buildDrawerTile(
              context: context,
              icon: Icons.person_add,
              title: 'Create Account',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppConstants.registerRoute);
              },
              isHighlighted: true,
            ),
          ],
          
          // App Section Header
          Padding(
            padding: const EdgeInsets.only(
              left: AppConstants.paddingL, 
              top: AppConstants.paddingL, 
              bottom: AppConstants.paddingS
            ),
            child: Text(
              'APP',
              style: TextStyle(
                fontSize: AppConstants.fontSizeXS,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          
          // Settings (for all users)
          _buildDrawerTile(
            context: context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.settingsRoute);
            },
          ),
          // About
          _buildDrawerTile(
            context: context,
            icon: Icons.info,
            title: 'About',
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isHighlighted
            ? Theme.of(context).colorScheme.primary
            : null,
        size: AppConstants.iconSizeM,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          fontSize: AppConstants.fontSizeM,
          color: isHighlighted
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onBackground,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingL,
        vertical: AppConstants.paddingXS,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      horizontalTitleGap: AppConstants.paddingM,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.videogame_asset,
          size: AppConstants.iconSizeL,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      children: [
        const SizedBox(height: AppConstants.paddingM),
        Text(
          AppConstants.appTagline,
          style: TextStyle(
            fontSize: AppConstants.fontSizeM,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),
        const Text(
          'Guide Genie helps gamers find and share strategies, tier lists, and loadouts for their favorite games. Create an account to contribute your own guides and join our community!',
          style: TextStyle(height: 1.5),
        ),
        const SizedBox(height: AppConstants.paddingL),
        const Text(
          '© 2023 Guide Genie. All rights reserved.',
          style: TextStyle(
            fontSize: AppConstants.fontSizeS,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}