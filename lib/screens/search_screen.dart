import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/models/guide_post.dart';
import 'package:guide_genie/providers/game_provider.dart';
import 'package:guide_genie/providers/post_provider.dart';
import 'package:guide_genie/utils/constants.dart';
import 'package:guide_genie/utils/ui_helper.dart';
import 'package:guide_genie/widgets/game_card.dart';
import 'package:guide_genie/widgets/guide_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  List<Game> _searchedGames = [];
  List<GuidePost> _searchedGuides = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load games and posts if not already loaded
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      
      if (gameProvider.games.isEmpty) {
        await gameProvider.loadGames();
      }
      
      if (postProvider.posts.isEmpty) {
        await postProvider.loadPosts();
      }
    } catch (e) {
      print('Error loading initial data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _performSearch(String query) {
    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });
    
    try {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      
      _searchedGames = gameProvider.searchGames(query) as List<Game>;
      _searchedGuides = postProvider.searchGuidePosts(query);
    } catch (e) {
      print('Error searching: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate safe area padding
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;
    final appBarHeight = kToolbarHeight;
    final tabBarHeight = 48.0; // Standard height for TabBar

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: UIHelper.gamingAppBar(
        title: 'Search',
        backgroundColor: AppConstants.gamingDarkPurple.withOpacity(0.85),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConstants.primaryNeon,
          indicatorWeight: 3,
          labelColor: AppConstants.primaryNeon,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'GAMES'),
            Tab(text: 'GUIDES'),
          ],
        ),
      ),
      body: Container(
        decoration: UIHelper.gamingGradientBackground(),
        child: Stack(
          children: [
            // Add subtle grid pattern background
            UIHelper.gridPatternOverlay(opacity: 0.05),
            
            Column(
              children: [
                // Add proper space for the AppBar including status bar, app bar, and tab bar
                SizedBox(height: statusBarHeight + appBarHeight + tabBarHeight), 
                
                // Search field with neon styling
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: UIHelper.neonContainer(
                    borderColor: AppConstants.primaryNeon,
                    glowIntensity: 0.5,
                    borderRadius: AppConstants.borderRadiusM,
                    padding: EdgeInsets.zero,
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search for games or guides...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        prefixIcon: const Icon(Icons.search, color: AppConstants.primaryNeon),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        ),
                        filled: true,
                        fillColor: AppConstants.gamingDarkBlue.withOpacity(0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingM,
                          vertical: AppConstants.paddingS,
                        ),
                      ),
                      onChanged: (value) {
                        _performSearch(value);
                      },
                      onSubmitted: (value) {
                        _performSearch(value);
                      },
                    ),
                  ),
                ),
                
                // Tab content
                Expanded(
                  child: _isLoading
                    ? Center(child: UIHelper.gamingProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildGamesTab(),
                          _buildGuidesTab(),
                        ],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesTab() {
    if (_searchQuery.isEmpty) {
      return _buildEmptySearchState(
        'Search for games',
        'Enter a game name, genre, or developer to search',
        Icons.games,
      );
    }
    
    if (_searchedGames.isEmpty) {
      return _buildNoResultsState('No games found matching "$_searchQuery"');
    }
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: AppConstants.paddingM,
          mainAxisSpacing: AppConstants.paddingM,
        ),
        itemCount: _searchedGames.length,
        itemBuilder: (context, index) {
          final game = _searchedGames[index];
          return GameCard(
            game: game,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppConstants.gameDetailsRoute,
                arguments: game.id,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGuidesTab() {
    if (_searchQuery.isEmpty) {
      return _buildEmptySearchState(
        'Search for guides',
        'Enter a guide title, type, or tag to search',
        Icons.menu_book,
      );
    }
    
    if (_searchedGuides.isEmpty) {
      return _buildNoResultsState('No guides found matching "$_searchQuery"');
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: _searchedGuides.length,
      itemBuilder: (context, index) {
        final guide = _searchedGuides[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
          child: GuideCard(
            guide: guide,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppConstants.guideDetailsRoute,
                arguments: guide.id,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptySearchState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppConstants.gamingDarkBlue.withOpacity(0.6),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryNeon.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
              border: Border.all(
                color: AppConstants.primaryNeon.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: 50,
              color: AppConstants.primaryNeon.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),
          Text(
            title,
            style: TextStyle(
              fontSize: AppConstants.fontSizeL,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
              shadows: [
                Shadow(
                  color: AppConstants.primaryNeon.withOpacity(0.5),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppConstants.fontSizeM,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppConstants.gamingDarkBlue.withOpacity(0.6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
              border: Border.all(
                color: Colors.redAccent.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.search_off,
              size: 40,
              color: Colors.redAccent.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.fontSizeM,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          UIHelper.neonButton(
            text: 'Clear Search',
            onPressed: () {
              _searchController.clear();
              _performSearch('');
            },
            isOutlined: true,
            textColor: Colors.white,
            borderColor: AppConstants.primaryNeon,
          ),
        ],
      ),
    );
  }
}