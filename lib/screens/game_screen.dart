import 'package:flutter/material.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/models/post.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:guide_genie/screens/post_screen.dart';
import 'package:guide_genie/widgets/custom_app_bar.dart';
import 'package:guide_genie/widgets/loading_indicator.dart';
import 'package:guide_genie/widgets/post_card.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  final Game game;

  const GameScreen({
    Key? key,
    required this.game,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load posts for this game when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).loadPostsForGame(widget.game.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToPostScreen(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(post: post),
      ),
    );
  }
  
  void _showCreatePostDialog() {
    // Show bottom sheet or navigate to a create post screen
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildCreatePostForm(),
    );
  }

  Widget _buildCreatePostForm() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create Post',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: contentController,
            decoration: const InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            maxLength: 1000,
          ),
          const SizedBox(height: 8),
          if (widget.game.categories.isNotEmpty)
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              value: _selectedCategory,
              items: widget.game.categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }
              
              // TODO: Implement create post functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post created successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('POST'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.game.name,
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Game Info Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Row(
              children: [
                // Game Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: Image.asset(
                    widget.game.logoUrl,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                // Game Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.game.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.game.description != null)
                        Text(
                          widget.game.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (widget.game.currentVersion != null)
                            _buildInfoChip(
                              'Version: ${widget.game.currentVersion!}',
                            ),
                          const SizedBox(width: 8),
                          if (widget.game.currentSeason != null)
                            _buildInfoChip(
                              'Season: ${widget.game.currentSeason!}',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Latest'),
              Tab(text: 'Hottest'),
            ],
          ),
          
          // Category Filter Chips
          if (widget.game.categories.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ...widget.game.categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: _selectedCategory == category,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          
          // Posts List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Latest Posts Tab
                _buildPostsList(postProvider.getLatestPosts()),
                
                // Hottest Posts Tab
                _buildPostsList(postProvider.getHottestPosts()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
  
  Widget _buildPostsList(List<Post> posts) {
    final postProvider = Provider.of<PostProvider>(context);
    
    if (postProvider.isLoading) {
      return const Center(
        child: LoadingIndicator(),
      );
    }
    
    if (postProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load posts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                postProvider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                postProvider.loadPostsForGame(widget.game.id);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    // Filter posts by category if selected
    final filteredPosts = _selectedCategory == null
        ? posts
        : posts.where((post) => post.tags.contains(_selectedCategory)).toList();
    
    if (filteredPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _selectedCategory == null
                  ? 'No posts available'
                  : 'No posts in $_selectedCategory category',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreatePostDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create a post'),
            ),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPosts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final post = filteredPosts[index];
        return PostCard(
          post: post,
          onTap: () => _navigateToPostScreen(post),
        );
      },
    );
  }
}
