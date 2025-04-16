import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/models/post.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/providers/game_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:guide_genie/utils/constants.dart';
import 'package:guide_genie/widgets/app_drawer.dart';
import 'package:guide_genie/widgets/game_card.dart';
import 'package:guide_genie/widgets/post_card.dart';
import 'package:guide_genie/widgets/featured_post_card.dart';
import 'package:guide_genie/widgets/loading_indicator.dart';
import 'package:guide_genie/widgets/error_message.dart';
import 'package:guide_genie/widgets/section_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    
    // Fetch featured games and posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      
      if (gameProvider.games.isEmpty) {
        gameProvider.fetchGames();
      }
      
      if (postProvider.featuredPosts.isEmpty) {
        postProvider.fetchFeaturedPosts();
      }
    });
  }

  void _scrollListener() {
    // Show app bar title after scrolling past a certain point
    if (_scrollController.offset > 150 && !_showAppBarTitle) {
      setState(() {
        _showAppBarTitle = true;
      });
    } else if (_scrollController.offset <= 150 && _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          _buildBody(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      title: _showAppBarTitle ? Text(AppConstants.appName) : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingL,
            AppConstants.paddingXL * 2,
            AppConstants.paddingL,
            AppConstants.paddingL,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                AppConstants.appName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: AppConstants.fontSizeXXXL,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingXS),
              Text(
                AppConstants.appTagline,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                  fontSize: AppConstants.fontSizeM,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.pushNamed(context, AppConstants.searchRoute);
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeaturedGames(),
            const SizedBox(height: AppConstants.paddingL),
            _buildFeaturedPosts(),
            const SizedBox(height: AppConstants.paddingL),
            _buildGuideTypes(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedGames() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        if (gameProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (gameProvider.errorMessage != null) {
          return ErrorMessage(
            message: gameProvider.errorMessage!,
            onRetry: () => gameProvider.fetchGames(),
          );
        }

        if (gameProvider.featuredGames.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            child: Text(AppConstants.emptyGamesList),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Featured Games'),
            SizedBox(
              height: AppConstants.gameCardHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                itemCount: gameProvider.featuredGames.length,
                itemBuilder: (context, index) {
                  final game = gameProvider.featuredGames[index];
                  return GameCard(game: game);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedPosts() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, _) {
        if (postProvider.isLoading) {
          return const LoadingIndicator();
        }

        if (postProvider.errorMessage != null) {
          return ErrorMessage(
            message: postProvider.errorMessage!,
            onRetry: () => postProvider.fetchFeaturedPosts(),
          );
        }

        if (postProvider.featuredPosts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            child: Text(AppConstants.emptyPostsList),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Featured Guides'),
            postProvider.featuredPosts.isNotEmpty
                ? FeaturedPostCard(post: postProvider.featuredPosts.first)
                : const SizedBox.shrink(),
            const SizedBox(height: AppConstants.paddingM),
            if (postProvider.featuredPosts.length > 1)
              SizedBox(
                height: AppConstants.postCardHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                  itemCount: postProvider.featuredPosts.length - 1,
                  itemBuilder: (context, index) {
                    // Skip the first post since it's displayed as featured
                    final post = postProvider.featuredPosts[index + 1];
                    return PostCard(post: post);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildGuideTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Guide Categories'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: AppConstants.paddingM,
            crossAxisSpacing: AppConstants.paddingM,
            children: GuideType.values.map((type) {
              return _buildGuideTypeCard(type);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideTypeCard(GuideType type) {
    final typeName = type.toString().split('.').last;
    
    return InkWell(
      onTap: () {
        // TODO: Navigate to guide type filter
      },
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppConstants.guideTypeIcons[typeName],
              size: AppConstants.iconSizeL,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              AppConstants.guideTypeNames[typeName] ?? typeName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppConstants.fontSizeS,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isAuthenticated) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppConstants.createPostRoute);
        },
        tooltip: 'Create Guide',
        child: const Icon(Icons.add),
      );
    }
    
    return null;
  }
}