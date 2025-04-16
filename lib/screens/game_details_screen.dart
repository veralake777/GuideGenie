import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/providers/auth_provider.dart';
import 'package:guide_genie/providers/game_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:guide_genie/utils/constants.dart';
import 'package:guide_genie/widgets/loading_indicator.dart';
import 'package:guide_genie/widgets/error_message.dart';
import 'package:guide_genie/widgets/post_card.dart';
import 'package:guide_genie/widgets/section_title.dart';

class GameDetailsScreen extends StatefulWidget {
  final String gameId;

  const GameDetailsScreen({
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  _GameDetailsScreenState createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch game details and posts for this game
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      
      gameProvider.fetchGameDetails(widget.gameId);
      postProvider.fetchPostsByGame(widget.gameId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
    final gameProvider = Provider.of<GameProvider>(context);
    final game = gameProvider.selectedGame;
    
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          game?.name ?? 'Game Details',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppConstants.fontSizeL,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
          child: game != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    // Game Cover Image
                    Image.network(
                      game.coverImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            size: 50,
                          ),
                        );
                      },
                    ),
                    // Gradient overlay for better text visibility
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
      actions: [
        // Favorite button
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isAuthenticated) {
              return IconButton(
                icon: Icon(
                  authProvider.isGameFavorite(widget.gameId)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: authProvider.isGameFavorite(widget.gameId)
                      ? Colors.red
                      : Colors.white,
                ),
                onPressed: () {
                  if (authProvider.isGameFavorite(widget.gameId)) {
                    authProvider.removeGameFromFavorites(widget.gameId);
                  } else {
                    authProvider.addGameToFavorites(widget.gameId);
                  }
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final game = gameProvider.selectedGame;
        
        if (gameProvider.isLoading) {
          return const SliverFillRemaining(
            child: LoadingIndicator(message: 'Loading game details...'),
          );
        }

        if (gameProvider.errorMessage != null) {
          return SliverFillRemaining(
            child: ErrorMessage(
              message: gameProvider.errorMessage!,
              onRetry: () => gameProvider.fetchGameDetails(widget.gameId),
            ),
          );
        }

        if (game == null) {
          return const SliverFillRemaining(
            child: Center(
              child: Text('Game not found'),
            ),
          );
        }

        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGameInfo(game),
              _buildGamePosts(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameInfo(Game game) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game description
          Text(
            game.description,
            style: TextStyle(
              fontSize: AppConstants.fontSizeM,
              height: 1.5,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),
          
          // Game metadata
          _buildMetadataItem('Developer', game.developer),
          _buildMetadataItem('Publisher', game.publisher),
          _buildMetadataItem('Release Date', game.releaseDate),
          _buildMetadataItem('Platforms', game.platforms.join(', ')),
          _buildMetadataItem('Genres', game.genres.join(', ')),
          const SizedBox(height: AppConstants.paddingL),
          
          // Rating
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: AppConstants.iconSizeM,
              ),
              const SizedBox(width: AppConstants.paddingS),
              Text(
                game.rating.toString(),
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeL,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppConstants.paddingS),
              Text(
                '(${game.postCount} guides)',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeM,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const Divider(height: AppConstants.paddingXL),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppConstants.fontSizeS,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppConstants.fontSizeS,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamePosts() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, _) {
        if (postProvider.isLoading) {
          return const LoadingIndicator(message: 'Loading guides...');
        }

        if (postProvider.errorMessage != null) {
          return ErrorMessage(
            message: postProvider.errorMessage!,
            onRetry: () => postProvider.fetchPostsByGame(widget.gameId),
          );
        }

        if (postProvider.posts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(AppConstants.paddingL),
            child: Center(
              child: Text(
                'No guides available for this game yet.\nBe the first to create one!',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Guides'),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
              itemCount: postProvider.posts.length,
              itemBuilder: (context, index) {
                return PostCard(post: postProvider.posts[index]);
              },
            ),
            const SizedBox(height: AppConstants.paddingXL),
          ],
        );
      },
    );
  }

  Widget? _buildFloatingActionButton() {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isAuthenticated) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppConstants.createPostRoute,
            arguments: {'gameId': widget.gameId},
          );
        },
        tooltip: 'Create Guide',
        child: const Icon(Icons.add),
      );
    }
    
    return null;
  }
}