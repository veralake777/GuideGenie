import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/models/post.dart';
import 'package:guide_genie/providers/game_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:guide_genie/utils/constants.dart';
import 'package:guide_genie/widgets/game_card.dart';
import 'package:guide_genie/widgets/post_card.dart';
import 'package:guide_genie/widgets/loading_indicator.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';
  bool _isSearching = false;
  
  List<Game> _filteredGames = [];
  List<Post> _filteredPosts = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize game and post data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      
      if (gameProvider.games.isEmpty) {
        gameProvider.fetchGames();
      }
      
      if (postProvider.posts.isEmpty) {
        postProvider.fetchPosts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.trim();
      _isSearching = _searchQuery.isNotEmpty;
      
      if (_isSearching) {
        final gameProvider = Provider.of<GameProvider>(context, listen: false);
        final postProvider = Provider.of<PostProvider>(context, listen: false);
        
        _filteredGames = gameProvider.searchGames(_searchQuery);
        _filteredPosts = postProvider.searchPosts(_searchQuery);
      } else {
        _filteredGames = [];
        _filteredPosts = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search games and guides',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                : null,
          ),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
          onChanged: (value) {
            if (value.isEmpty) {
              _performSearch('');
            }
          },
          autofocus: true,
        ),
      ),
      body: _isSearching
          ? Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      text: 'Games (${_filteredGames.length})',
                    ),
                    Tab(
                      text: 'Guides (${_filteredPosts.length})',
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGamesSearchResults(),
                      _buildPostsSearchResults(),
                    ],
                  ),
                ),
              ],
            )
          : _buildSearchPrompt(),
    );
  }

  Widget _buildSearchPrompt() {
    final gameProvider = Provider.of<GameProvider>(context);
    
    if (gameProvider.isLoading) {
      return const LoadingIndicator(message: 'Loading data...');
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.paddingL),
          const Text(
            'Search for games and guides',
            style: TextStyle(
              fontSize: AppConstants.fontSizeL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          const Text(
            'Type in the search bar above to find content',
            style: TextStyle(
              fontSize: AppConstants.fontSizeM,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: AppConstants.paddingXL),
          
          // Popular searches
          if (gameProvider.games.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingL,
                vertical: AppConstants.paddingM,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Popular Games',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeM,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
                itemCount: gameProvider.games.length > 5 ? 5 : gameProvider.games.length,
                itemBuilder: (context, index) {
                  final game = gameProvider.games[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: AppConstants.paddingS),
                    child: ActionChip(
                      label: Text(game.name),
                      onPressed: () {
                        _searchController.text = game.name;
                        _performSearch(game.name);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingL,
                vertical: AppConstants.paddingM,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Popular Guide Types',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeM,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
                itemCount: AppConstants.guideTypeNames.length,
                itemBuilder: (context, index) {
                  final type = AppConstants.guideTypeNames.values.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.only(right: AppConstants.paddingS),
                    child: ActionChip(
                      label: Text(type),
                      onPressed: () {
                        _searchController.text = type;
                        _performSearch(type);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGamesSearchResults() {
    if (_filteredGames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videogame_asset_off,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.paddingL),
            Text(
              'No games found for "$_searchQuery"',
              style: const TextStyle(
                fontSize: AppConstants.fontSizeL,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: _filteredGames.length,
      itemBuilder: (context, index) {
        final game = _filteredGames[index];
        return GameCard(game: game);
      },
    );
  }

  Widget _buildPostsSearchResults() {
    if (_filteredPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.paddingL),
            Text(
              'No guides found for "$_searchQuery"',
              style: const TextStyle(
                fontSize: AppConstants.fontSizeL,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: _filteredPosts.length,
      itemBuilder: (context, index) {
        final post = _filteredPosts[index];
        return PostCard(post: post);
      },
    );
  }
}