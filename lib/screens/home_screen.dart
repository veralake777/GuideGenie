import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game.dart';
import '../models/guide_post.dart';
import '../providers/game_provider.dart';
import '../providers/post_provider.dart';
import '../utils/constants.dart';
import '../utils/ui_helper.dart';
import '../widgets/app_drawer.dart';
import '../widgets/featured_game_card.dart';
import '../widgets/popular_guide_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: Curves.easeOut,
      ),
    );
    
    _loadData();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      
      // Start animation after data is loaded
      _animationController.forward();
      
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
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
      extendBodyBehindAppBar: true,
      appBar: UIHelper.gamingAppBar(
        title: AppConstants.appName,
        backgroundColor: Colors.transparent,
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
                SnackBar(
                  content: const Text('Notifications feature coming soon!'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppConstants.gamingDarkPurple,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: UIHelper.gamingGradientBackground(),
        child: Stack(
          children: [
            // Add subtle grid pattern background
            UIHelper.gridPatternOverlay(opacity: 0.05),
            
            // Main content
            isLoading
              ? Center(child: UIHelper.gamingProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppConstants.primaryNeon,
                  backgroundColor: AppConstants.gamingDarkPurple,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: kToolbarHeight + 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Featured games section
                            UIHelper.sectionTitle(
                              'Featured Games',
                              context,
                              onSeeAllPressed: () {
                                // Navigate to all games screen
                                Navigator.pushNamed(context, AppConstants.allGamesRoute);
                              },
                            ),
                            
                            // Featured games carousel
                            if (featuredGames.isEmpty)
                              UIHelper.emptyState(
                                message: 'No featured games available yet. Check back soon for updates!',
                                icon: Icons.games,
                              )
                            else
                              _buildFeaturedGamesCarousel(featuredGames),
                            
                            // Popular guides section
                            UIHelper.sectionTitle(
                              'Popular Guides',
                              context,
                              onSeeAllPressed: () {
                                // Navigate to all guides screen
                                Navigator.pushNamed(context, AppConstants.allGuidesRoute);
                              },
                            ),
                            
                            // Popular guides list
                            if (popularGuides.isEmpty)
                              UIHelper.emptyState(
                                message: 'Be the first to create a popular guide!',
                                icon: Icons.menu_book,
                                actionText: 'Create Guide',
                                onActionPressed: () {
                                  Navigator.pushNamed(context, AppConstants.createPostRoute);
                                },
                              )
                            else
                              _buildPopularGuidesList(popularGuides),
                              
                            // Add some space at the bottom
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
      floatingActionButton: isLoading 
          ? null
          : _buildFloatingActionButton(),
    );
  }
  
  Widget _buildFeaturedGamesCarousel(List<Game> featuredGames) {
    return Container(
      height: 180,
      margin: const EdgeInsets.only(bottom: AppConstants.paddingL),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
        scrollDirection: Axis.horizontal,
        itemCount: featuredGames.length,
        itemBuilder: (context, index) {
          // Add staggered animation for each card
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0.2 * (index + 1), 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    0.2 + (index * 0.1),
                    0.8 + (index * 0.05),
                    curve: Curves.easeOutCubic,
                  ),
                ),
              ),
              child: FeaturedGameCard(game: featuredGames[index]),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildPopularGuidesList(List<GuidePost> guides) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: guides.length,
        itemBuilder: (context, index) {
          // Add staggered animation for each card
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    0.4 + (index * 0.05),
                    0.9 + (index * 0.03),
                    curve: Curves.easeOutCubic,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
                child: PopularGuideCard(guide: guides[index]),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppConstants.accentNeon.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppConstants.createPostRoute);
        },
        backgroundColor: AppConstants.gamingDarkPurple,
        foregroundColor: AppConstants.accentNeon,
        elevation: 8,
        child: const Icon(Icons.add),
      ),
    );
  }
}