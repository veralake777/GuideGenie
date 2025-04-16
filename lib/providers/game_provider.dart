import 'package:flutter/material.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/services/api_service.dart';

class GameProvider with ChangeNotifier {
  List<Game> _games = [];
  bool _isLoading = false;
  String? _errorMessage;
  Game? _selectedGame;

  final ApiService _apiService = ApiService();

  List<Game> get games => _games;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Game? get selectedGame => _selectedGame;

  // Filter games by priority
  List<Game> getGamesByPriority(GamePriority priority) {
    return _games.where((game) => game.priority == priority).toList();
  }

  // Get all P0 games (highest priority)
  List<Game> get p0Games => getGamesByPriority(GamePriority.p0);

  // Get all P1 games (medium priority)
  List<Game> get p1Games => getGamesByPriority(GamePriority.p1);

  // Get all P2 games (lowest priority)
  List<Game> get p2Games => getGamesByPriority(GamePriority.p2);

  // Load all games from the API
  Future<void> loadGames() async {
    if (_games.isNotEmpty) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final gamesData = await _apiService.getGames();
      _games = gamesData.map((gameJson) => Game.fromJson(gameJson)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load games: ${e.toString()}';
      
      // If API fails, load default games (P0 games)
      _loadDefaultGames();
      
      notifyListeners();
    }
  }

  // Select a game to display its details
  void selectGame(Game game) {
    _selectedGame = game;
    notifyListeners();
  }

  // Clear the selected game
  void clearSelectedGame() {
    _selectedGame = null;
    notifyListeners();
  }

  // Get a game by its ID
  Game? getGameById(String id) {
    try {
      return _games.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }

  // Load default games in case API fails
  void _loadDefaultGames() {
    _games = [
      Game(
        id: 'fortnite',
        name: 'Fortnite',
        logoUrl: 'assets/game_logos/fortnite.svg',
        priority: GamePriority.p0,
        description: 'Battle royale game by Epic Games',
        currentSeason: 'Chapter 4, Season 3',
        categories: ['Battle Royale', 'Weapons', 'Characters', 'Strategies'],
      ),
      Game(
        id: 'league_of_legends',
        name: 'League of Legends',
        logoUrl: 'assets/game_logos/league_of_legends.svg',
        priority: GamePriority.p0,
        description: 'MOBA game by Riot Games',
        currentSeason: 'Season 13',
        categories: ['Champions', 'Items', 'Runes', 'Strategies'],
      ),
      Game(
        id: 'valorant',
        name: 'Valorant',
        logoUrl: 'assets/game_logos/valorant.svg',
        priority: GamePriority.p0,
        description: 'Tactical shooter by Riot Games',
        currentSeason: 'Episode 6, Act 3',
        categories: ['Agents', 'Maps', 'Weapons', 'Strategies'],
      ),
      Game(
        id: 'street_fighter',
        name: 'Street Fighter 6',
        logoUrl: 'assets/game_logos/street_fighter.svg',
        priority: GamePriority.p0,
        description: 'Fighting game by Capcom',
        currentVersion: 'v1.22',
        categories: ['Characters', 'Combos', 'Tier Lists', 'Strategies'],
      ),
      Game(
        id: 'call_of_duty',
        name: 'Call of Duty',
        logoUrl: 'assets/game_logos/call_of_duty.svg',
        priority: GamePriority.p0,
        description: 'FPS game by Activision',
        currentVersion: 'Modern Warfare III',
        categories: ['Weapons', 'Loadouts', 'Maps', 'Strategies'],
      ),
      Game(
        id: 'warzone',
        name: 'Call of Duty: Warzone',
        logoUrl: 'assets/game_logos/warzone.svg',
        priority: GamePriority.p0,
        description: 'Battle royale game by Activision',
        currentSeason: 'Season 3',
        categories: ['Weapons', 'Loadouts', 'Maps', 'Strategies'],
      ),
      Game(
        id: 'marvel_rivals',
        name: 'Marvel Rivals',
        logoUrl: 'assets/game_logos/marvel_rivals.svg',
        priority: GamePriority.p0,
        description: 'Superhero team-based game',
        currentVersion: 'Beta',
        categories: ['Characters', 'Abilities', 'Strategies'],
      ),
    ];
  }
}
