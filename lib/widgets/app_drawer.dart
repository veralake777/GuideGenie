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
      child: Column(
        children: [
          _buildDrawerHeader(context, isLoggedIn, user),
          _buildDrawerItems(context, isLoggedIn),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, bool isLoggedIn, dynamic user) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      padding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App icon and name
            Row(
              children: [
                Icon(
                  Icons.videogame_asset,
                  size: AppConstants.iconSizeL,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(width: AppConstants.paddingS),
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
            const Spacer(),
            // User info (if logged in) or login prompt
            if (isLoggedIn && user != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: user.avatarUrl != null 
                        ? NetworkImage(user.avatarUrl!) 
                        : null,
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: user.avatarUrl == null
                        ? Text(
                            user.username[0].toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
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
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
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
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.pushNamed(context, AppConstants.loginRoute);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Login / Register'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItems(BuildContext context, bool isLoggedIn) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Home
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
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
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.searchRoute);
            },
          ),
          // Browse Games
          ListTile(
            leading: const Icon(Icons.videogame_asset),
            title: const Text('Browse Games'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to games list
            },
          ),
          // Guide Categories
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Guide Categories'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to categories
            },
          ),
          // Divider between common and user-specific options
          const Divider(),
          // User-specific options
          if (isLoggedIn) ...[
            // Profile
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppConstants.profileRoute);
              },
            ),
            // My Guides
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('My Guides'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to user's guides
              },
            ),
            // Favorites
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favorites'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to favorites
              },
            ),
            // Create Guide
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Create Guide'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppConstants.createPostRoute);
              },
            ),
            // Logout
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
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
          ],
          // Settings (for all users)
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppConstants.settingsRoute);
            },
          ),
          // About
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Icon(
        Icons.videogame_asset,
        size: AppConstants.iconSizeL,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const SizedBox(height: AppConstants.paddingM),
        Text(
          AppConstants.appTagline,
          style: TextStyle(
            fontSize: AppConstants.fontSizeM,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),
        const Text(
          'Guide Genie helps gamers find and share strategies, tier lists, and loadouts for their favorite games. Create an account to contribute your own guides and join our community!',
        ),
        const SizedBox(height: AppConstants.paddingM),
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