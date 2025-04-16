import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../models/guide_post.dart';
import '../providers/game_provider.dart';
import '../providers/post_provider.dart';
import '../utils/constants.dart';
import '../widgets/app_drawer.dart';
import '../widgets/featured_game_card.dart';
import '../widgets/popular_guide_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      // Load data from providers
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      
      // Load games and posts concurrently
      await Future.wait([
        gameProvider.loadGames(),
        postProvider.loadPosts(),
      ]);
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    
    final featuredGames = gameProvider.getFeaturedGames();
    final popularGuides = postProvider.getPopularPosts();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guide Genie',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, AppConstants.searchRoute);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications feature coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured games section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Featured Games',
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to all games screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('All Games feature coming soon!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Text(
                              'See All',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Featured games carousel
                    if (featuredGames.isEmpty)
                      _buildEmptyState('No featured games available', Icons.games)
                    else
                      SizedBox(
                        height: 170,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          scrollDirection: Axis.horizontal,
                          itemCount: featuredGames.length,
                          itemBuilder: (context, index) {
                            return FeaturedGameCard(game: featuredGames[index]);
                          },
                        ),
                      ),
                    
                    // Popular guides section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Popular Guides',
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to all guides screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('All Guides feature coming soon!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Text(
                              'See All',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Popular guides list
                    if (popularGuides.isEmpty)
                      _buildEmptyState('No popular guides available', Icons.menu_book)
                    else
                      ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: popularGuides.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PopularGuideCard(guide: popularGuides[index]),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppConstants.createPostRoute);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}