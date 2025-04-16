import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/providers/game_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:guide_genie/utils/constants.dart';
import 'package:guide_genie/widgets/app_drawer.dart';
import 'package:guide_genie/widgets/featured_post_card.dart';
import 'package:guide_genie/widgets/game_card.dart';
import 'package:guide_genie/widgets/post_card.dart';
import 'package:guide_genie/widgets/loading_indicator.dart';
import 'package:guide_genie/widgets/error_message.dart';
import 'package:guide_genie/widgets/section_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch initial data
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      
      gameProvider.fetchGames();
      postProvider.fetchFeaturedPosts();
      postProvider.fetchLatestPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              Navigator.pushNamed(context, AppConstants.searchRoute);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          final gameProvider = Provider.of<GameProvider>(context, listen: false);
          final postProvider = Provider.of<PostProvider>(context, listen: false);
          
          await gameProvider.fetchGames();
          await postProvider.fetchFeaturedPosts();
          await postProvider.fetchLatestPosts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeaturedPosts(),
              _buildPopularGames(),
              _buildLatestGuides(),
              _buildGameCategories(),
              const SizedBox(height: AppConstants.paddingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedPosts() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, _) {
        if (postProvider.isLoading && postProvider.featuredPosts.isEmpty) {
          return const SizedBox(
            height: 300,
            child: LoadingIndicator(message: 'Loading featured guides...'),
          );
        }

        if (postProvider.errorMessage != null && postProvider.featuredPosts.isEmpty) {
          return SizedBox(
            height: 300,
            child: ErrorMessage(
              message: postProvider.errorMessage!,
              onRetry: () => postProvider.fetchFeaturedPosts(),
            ),
          );
        }

        if (postProvider.featuredPosts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: 'Featured Guides',
              subtitle: 'Trending content selected for you',
            ),
            SizedBox(
              height: 350,
              child: PageView.builder(
                padEnds: false,
                controller: PageController(viewportFraction: 0.9),
                itemCount: postProvider.featuredPosts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingS,
                    ),
                    child: FeaturedPostCard(post: postProvider.featuredPosts[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPopularGames() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        if (gameProvider.isLoading && gameProvider.games.isEmpty) {
          return const SizedBox(
            height: 200,
            child: LoadingIndicator(message: 'Loading popular games...'),
          );
        }

        if (gameProvider.errorMessage != null && gameProvider.games.isEmpty) {
          return SizedBox(
            height: 200,
            child: ErrorMessage(
              message: gameProvider.errorMessage!,
              onRetry: () => gameProvider.fetchGames(),
            ),
          );
        }

        if (gameProvider.games.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text('No games found'),
            ),
          );
        }

        // Filter featured games
        final featuredGames = gameProvider.games
            .where((game) => game.isFeatured)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: 'Popular Games',
              subtitle: 'Check out guides for these trending games',
              onSeeAll: () {
                // TODO: Navigate to games list
              },
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingM,
                ),
                itemCount: featuredGames.isEmpty 
                    ? gameProvider.games.length 
                    : featuredGames.length,
                itemBuilder: (context, index) {
                  final game = featuredGames.isEmpty 
                      ? gameProvider.games[index] 
                      : featuredGames[index];
                  
                  return GameCard(
                    game: game,
                    isCompact: true,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLatestGuides() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, _) {
        if (postProvider.isLoading && postProvider.latestPosts.isEmpty) {
          return const SizedBox(
            height: 200,
            child: LoadingIndicator(message: 'Loading latest guides...'),
          );
        }

        if (postProvider.errorMessage != null && postProvider.latestPosts.isEmpty) {
          return SizedBox(
            height: 200,
            child: ErrorMessage(
              message: postProvider.errorMessage!,
              onRetry: () => postProvider.fetchLatestPosts(),
            ),
          );
        }

        if (postProvider.latestPosts.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text('No guides found'),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: 'Latest Guides',
              subtitle: 'Fresh guides from the community',
              onSeeAll: () {
                // TODO: Navigate to posts list
              },
            ),
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingM,
                ),
                itemCount: postProvider.latestPosts.length,
                itemBuilder: (context, index) {
                  return PostCard(post: postProvider.latestPosts[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGameCategories() {
    final categories = [
      {'icon': Icons.sports_esports, 'title': 'Shooter', 'color': Colors.red},
      {'icon': Icons.public, 'title': 'MOBA', 'color': Colors.blue},
      {'icon': Icons.fitness_center, 'title': 'Fighting', 'color': Colors.orange},
      {'icon': Icons.style, 'title': 'Battle Royale', 'color': Colors.purple},
      {'icon': Icons.directions_run, 'title': 'Action', 'color': Colors.green},
      {'icon': Icons.psychology, 'title': 'Strategy', 'color': Colors.indigo},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Game Categories',
          subtitle: 'Find games by genre',
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingL,
            vertical: AppConstants.paddingS,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: AppConstants.paddingM,
            mainAxisSpacing: AppConstants.paddingM,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryItem(
              icon: category['icon'] as IconData,
              title: category['title'] as String,
              color: category['color'] as Color,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to category games
      },
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppConstants.iconSizeL,
              color: color,
            ),
            const SizedBox(height: AppConstants.paddingXS),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppConstants.fontSizeM,
              ),
            ),
          ],
        ),
      ),
    );
  }
}