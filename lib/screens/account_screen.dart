import 'package:flutter/material.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Account',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        user?.username.substring(0, 1).toUpperCase() ?? 'G',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Username
                    Text(
                      user?.username ?? 'Guest User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Email
                    if (user?.email != null)
                      Text(
                        user!.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Edit profile button
                    if (authProvider.isAuthenticated)
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to edit profile screen
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Account settings section
            const Text(
              'Account Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Card(
              elevation: 2,
              child: Column(
                children: [
                  // Notification settings
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notification Settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to notification settings screen
                    },
                  ),
                  
                  const Divider(height: 1),
                  
                  // Theme settings
                  ListTile(
                    leading: const Icon(Icons.color_lens),
                    title: const Text('App Theme'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to theme settings screen
                    },
                  ),
                  
                  if (authProvider.isAuthenticated) ...[
                    const Divider(height: 1),
                    
                    // Change password
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Navigate to change password screen
                      },
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // App info section
            const Text(
              'App Info',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Card(
              elevation: 2,
              child: Column(
                children: [
                  // About
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About Guide Genie'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Show about dialog
                    },
                  ),
                  
                  const Divider(height: 1),
                  
                  // Privacy policy
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Show privacy policy
                    },
                  ),
                  
                  const Divider(height: 1),
                  
                  // Terms of service
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Show terms of service
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Authentication section
            if (authProvider.isAuthenticated) ...[
              // Logout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    authProvider.logout();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else ...[
              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to login screen
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
