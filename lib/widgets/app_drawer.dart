import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/utils/constants.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthenticated = authProvider.isAuthenticated;
    final currentUser = authProvider.currentUser;

    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Guide Genie',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your Ultimate Gaming Companion',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  if (isAuthenticated && currentUser != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          backgroundImage: currentUser.avatarUrl != null && currentUser.avatarUrl!.isNotEmpty
                              ? NetworkImage(currentUser.avatarUrl!)
                              : null,
                          child: currentUser.avatarUrl == null || currentUser.avatarUrl!.isEmpty
                              ? Text(
                                  currentUser.username.isNotEmpty
                                      ? currentUser.username[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currentUser.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Navigation items
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All Games feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bookmarks feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
            
            const Divider(color: Colors.grey),
            
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
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: AppConstants.appVersion,
                  applicationIcon: const Icon(Icons.videogame_asset, size: 48, color: Color(0xFF5865F2)),
                  applicationLegalese: '© 2024 Guide Genie',
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'Guide Genie is your ultimate gaming companion, providing access to community-driven guides, tier lists, and strategies for your favorite games.',
                    ),
                  ],
                );
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
                onTap: () async {
                  Navigator.pop(context);
                  await authProvider.logout();
                  Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
                },
              ),
            ] else ...[
              // Not logged in state - Login and Register buttons
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppConstants.loginRoute);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Log In'),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppConstants.registerRoute);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Sign Up'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Function onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).primaryColor
            : Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => onTap(),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}