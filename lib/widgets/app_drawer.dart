import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: const Border(
                bottom: BorderSide(
                  color: Color(0xFF272935),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Guide Genie',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'The ultimate gaming companion',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home_outlined,
            title: 'Home',
            isSelected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.games_outlined,
            title: 'Games',
            onTap: () {
              // TODO: Navigate to games screen
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.trending_up_outlined,
            title: 'Trending Guides',
            onTap: () {
              // TODO: Navigate to trending guides screen
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.bookmarks_outlined,
            title: 'Saved Guides',
            onTap: () {
              // TODO: Navigate to saved guides screen
              Navigator.pop(context);
            },
          ),
          const Divider(
            height: 32,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: Color(0xFF272935),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person_outline,
            title: 'Profile',
            onTap: () {
              // TODO: Navigate to profile screen
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              // TODO: Navigate to settings screen
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              // TODO: Navigate to about screen
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement sign out
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).primaryColor
            : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).primaryColor
              : null,
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 2,
      ),
    );
  }
}