import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                // Already on home screen, no navigation needed
              },
            ),
            
            _buildDrawerItem(
              context,
              icon: Icons.search,
              title: 'Explore',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to explore screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Explore feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            
            _buildDrawerItem(
              context,
              icon: Icons.games,
              title: 'All Games',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to games list screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All Games feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            
            _buildDrawerItem(
              context,
              icon: Icons.bookmark,
              title: 'Bookmarks',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to bookmarks screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bookmarks feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            
            const Divider(color: Colors.grey),
            
            _buildDrawerItem(
              context,
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            
            _buildDrawerItem(
              context,
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {
                Navigator.pop(context);
                // TODO: Show about dialog
                showAboutDialog(
                  context: context,
                  applicationName: 'Guide Genie',
                  applicationVersion: '1.0.0',
                  applicationIcon: const FlutterLogo(),
                  applicationLegalese: '© 2023 Guide Genie',
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      'Guide Genie is your ultimate gaming companion, providing access to community-driven guides, tier lists, and strategies for your favorite games.',
                    ),
                  ],
                );
              },
            ),
            
            // Not logged in state
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Navigate to login screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Login feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
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
                  // TODO: Navigate to signup screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sign Up feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
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