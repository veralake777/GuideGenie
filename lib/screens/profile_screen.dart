import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Not logged in',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeL,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () {
              // TODO: Navigate to edit profile screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.username[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                  
                  const SizedBox(height: AppConstants.paddingL),
                  
                  // Username
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeXL,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: AppConstants.paddingS),
                  
                  // Email
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeM,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.paddingM),
                    Text(
                      user.bio!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeS,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: AppConstants.paddingL),
                  
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        context,
                        user.reputation.toString(),
                        'Reputation',
                      ),
                      _buildStatItem(
                        context,
                        '${user.favoriteGames.length}',
                        'Favorites',
                      ),
                      _buildStatItem(
                        context,
                        _getFormattedDate(user.createdAt),
                        'Joined',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Section title: My Content
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Content',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeL,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  _buildContentCard(
                    context,
                    Icons.book,
                    'My Guides',
                    'Manage and view your guides',
                    () {
                      // TODO: Navigate to my guides screen
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  _buildContentCard(
                    context,
                    Icons.favorite,
                    'Favorite Games',
                    'View your favorite games',
                    () {
                      // TODO: Navigate to favorite games screen
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  _buildContentCard(
                    context,
                    Icons.add_circle,
                    'Create New Guide',
                    'Share your knowledge with the community',
                    () {
                      Navigator.pushNamed(context, AppConstants.createPostRoute);
                    },
                  ),
                ],
              ),
            ),
            
            // Section title: Account Settings
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Settings',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeL,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  _buildSettingsItem(
                    context,
                    Icons.settings,
                    'App Settings',
                    () {
                      Navigator.pushNamed(context, AppConstants.settingsRoute);
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    Icons.security,
                    'Privacy & Security',
                    () {
                      // TODO: Navigate to privacy settings
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    Icons.help,
                    'Help & Support',
                    () {
                      // TODO: Navigate to help & support
                    },
                  ),
                  _buildSettingsItem(
                    context,
                    Icons.logout,
                    'Logout',
                    () async {
                      await authProvider.logout();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppConstants.homeRoute,
                        (route) => false,
                      );
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeL,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppConstants.fontSizeXS,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildContentCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
                ),
                child: Icon(
                  icon,
                  size: AppConstants.iconSizeL,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeM,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeS,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: AppConstants.iconSizeS,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  String _getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 365) {
      return '${difference.inDays} days';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years yr${years > 1 ? 's' : ''}';
    }
  }
}