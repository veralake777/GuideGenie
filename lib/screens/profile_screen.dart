import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/providers/game_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:guide_genie/utils/constants.dart';
import 'package:guide_genie/widgets/game_card.dart';
import 'package:guide_genie/widgets/loading_indicator.dart';
import 'package:guide_genie/widgets/error_message.dart';
import 'package:guide_genie/widgets/post_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;
  
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null) {
      _usernameController.text = user.username;
      _bioController.text = user.bio ?? '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (!authProvider.isAuthenticated) {
      return _buildUnauthenticatedView();
    }
    
    final user = authProvider.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('User data not available')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  
                  // Reset controllers to current values
                  _usernameController.text = user.username;
                  _bioController.text = user.bio ?? '';
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _isEditing ? _buildEditProfileForm(user, authProvider) : _buildProfileHeader(user),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'My Guides'),
              Tab(text: 'Favorite Games'),
              Tab(text: 'Stats'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyGuides(),
                _buildFavoriteGames(),
                _buildUserStats(user),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.paddingL),
            const Text(
              'You need to log in to view your profile',
              style: TextStyle(
                fontSize: AppConstants.fontSizeL,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppConstants.loginRoute);
              },
              child: const Text('Log In'),
            ),
            const SizedBox(height: AppConstants.paddingS),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppConstants.registerRoute);
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl) : null,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: user.avatarUrl == null 
                ? Text(
                    user.username[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ) 
                : null,
          ),
          const SizedBox(height: AppConstants.paddingM),
          Text(
            user.username,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingXS),
          Text(
            user.email,
            style: TextStyle(
              fontSize: AppConstants.fontSizeM,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingM),
            Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.fontSizeS,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.9),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: AppConstants.paddingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(user.favoriteGames.length, 'Favorites'),
              _buildDivider(),
              _buildStatItem(user.reputation, 'Reputation'),
              _buildDivider(),
              _buildStatItem(user.upvotedPosts.length, 'Upvotes'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileForm(user, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl) : null,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: user.avatarUrl == null 
                  ? Text(
                      user.username[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ) 
                  : null,
            ),
            const SizedBox(height: AppConstants.paddingM),
            
            // Username field
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a username';
                }
                if (value.length < 3) {
                  return 'Username must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: AppConstants.paddingM),
            
            // Bio field
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
                hintText: 'Tell us about yourself',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppConstants.paddingM),
            
            // Save button
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final success = await authProvider.updateProfile(
                    username: _usernameController.text.trim(),
                    bio: _bioController.text.trim(),
                  );
                  
                  if (success) {
                    setState(() {
                      _isEditing = false;
                    });
                    
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(authProvider.errorMessage ?? 'Failed to update profile'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: authProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyGuides() {
    // In a real app, we would fetch the user's guides from the API
    // For now, return a placeholder
    return const Center(
      child: Text('You haven\'t created any guides yet'),
    );
  }

  Widget _buildFavoriteGames() {
    final authProvider = Provider.of<AuthProvider>(context);
    final gameProvider = Provider.of<GameProvider>(context);
    final favoriteGameIds = authProvider.currentUser?.favoriteGames ?? [];
    
    if (gameProvider.isLoading) {
      return const LoadingIndicator();
    }
    
    if (gameProvider.errorMessage != null) {
      return ErrorMessage(
        message: gameProvider.errorMessage!,
        onRetry: () => gameProvider.fetchGames(),
      );
    }
    
    if (favoriteGameIds.isEmpty) {
      return const Center(
        child: Text('You haven\'t added any favorite games yet'),
      );
    }
    
    final favoriteGames = gameProvider.games
        .where((game) => favoriteGameIds.contains(game.id))
        .toList();
    
    if (favoriteGames.isEmpty) {
      return const Center(
        child: Text('Your favorite games couldn\'t be found'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: favoriteGames.length,
      itemBuilder: (context, index) {
        return GameCard(
          game: favoriteGames[index],
          isCompact: false,
        );
      },
    );
  }

  Widget _buildUserStats(user) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Statistics',
            style: TextStyle(
              fontSize: AppConstants.fontSizeL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),
          _buildStatRow('Account created', _formatDate(user.createdAt)),
          _buildStatRow('Last login', _formatDate(user.lastLogin)),
          _buildStatRow('Favorite games', user.favoriteGames.length.toString()),
          _buildStatRow('Reputation points', user.reputation.toString()),
          _buildStatRow('Upvoted posts', user.upvotedPosts.length.toString()),
          _buildStatRow('Downvoted posts', user.downvotedPosts.length.toString()),
          _buildStatRow('Upvoted comments', user.upvotedComments.length.toString()),
          _buildStatRow('Downvoted comments', user.downvotedComments.length.toString()),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppConstants.fontSizeM,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeM,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(int value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: AppConstants.fontSizeL,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: AppConstants.fontSizeS,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Theme.of(context).dividerColor,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}