import 'package:flutter/material.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/services/api_service_new.dart';
import 'package:guide_genie/utils/constants.dart';
import 'package:guide_genie/utils/ui_helper.dart';
import 'package:guide_genie/widgets/game_card.dart';
import 'package:guide_genie/widgets/loading_indicator.dart';

class AllGamesScreen extends StatefulWidget {
  const AllGamesScreen({Key? key}) : super(key: key);

  @override
  _AllGamesScreenState createState() => _AllGamesScreenState();
}

class _AllGamesScreenState extends State<AllGamesScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Game> _games = [];
  String _selectedCategory = 'All';
  
  final List<String> _categories = [
    'All',
    'Battle Royale',
    'MOBA',
    'FPS',
    'Fighting',
    'Strategy',
    'Sports',
    'Racing',
    'RPG',
  ];

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final gameList = await _apiService.getGames();
      setState(() {
        _games = gameList.map((json) => Game.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading games: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load games: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Game> _getFilteredGames() {
    if (_selectedCategory == 'All') {
      return _games;
    } else {
      return _games.where((game) => game.genre == _selectedCategory).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Games'),
        elevation: 0,
      ),
      body: Container(
        decoration: UIHelper.gamingGradientBackground(),
        child: Stack(
          children: [
            // Add grid pattern overlay
            UIHelper.gridPatternOverlay(opacity: 0.05),
            
            Column(
              children: [
                // Category filter pills
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == _selectedCategory;
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(category),
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            backgroundColor: Colors.grey[800],
                            selectedColor: AppConstants.primaryNeon.withOpacity(0.2),
                            checkmarkColor: AppConstants.primaryNeon,
                            labelStyle: TextStyle(
                              color: isSelected ? AppConstants.primaryNeon : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppConstants.primaryNeon : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            elevation: 0,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Game grid
                Expanded(
                  child: _isLoading
                      ? const Center(child: LoadingIndicator())
                      : _games.isEmpty
                          ? Center(
                              child: Text(
                                'No games found',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.builder(
                                padding: const EdgeInsets.only(bottom: 16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: _getFilteredGames().length,
                                itemBuilder: (context, index) {
                                  final game = _getFilteredGames()[index];
                                  return GameCard(
                                    game: game,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppConstants.gameDetailsRoute,
                                        arguments: {'gameId': game.id},
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}