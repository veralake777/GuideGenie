import 'package:flutter/material.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/services/api_service.dart';

enum GameCategory {
  battleRoyale,
  moba,
  fps,
  fighting,
  action,
  strategy,
  sports,
  rpg,
  adventure,
  simulation,
  puzzle,
  racing,
  other
}

class GameProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Game> _games = [];
  Game? _selectedGame;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Game> get games => _games;
  Game? get selectedGame => _selectedGame;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load/Fetch all games - alias for better naming
  Future<void> loadGames() async {
    return fetchGames();
  }

  // Fetch all games
  Future<void> fetchGames() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final gamesData = await _apiService.getGames();
      _games = gamesData.map((data) => Game.fromJson(data)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e; // Re-throw for the caller to handle
    }
  }

  // Fetch game details
  Future<void> fetchGameDetails(String gameId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final gameData = await _apiService.getGameDetails(gameId);
      _selectedGame = Game.fromJson(gameData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e; // Re-throw for the caller to handle
    }
  }

  // Get game by ID (local)
  Game? getGameById(String gameId) {
    try {
      return _games.firstWhere((game) => game.id == gameId);
    } catch (e) {
      return null;
    }
  }

  // Search games by query
  List<Game> searchGames(String query) {
    if (query.isEmpty) return _games;
    
    final lowerCaseQuery = query.toLowerCase();
    
    return _games.where((game) {
      return (game.name.isNotEmpty && game.name.toLowerCase().contains(lowerCaseQuery)) ||
          (game.title.isNotEmpty && game.title.toLowerCase().contains(lowerCaseQuery)) ||
          game.description.toLowerCase().contains(lowerCaseQuery) ||
          game.developer.toLowerCase().contains(lowerCaseQuery) ||
          game.publisher.toLowerCase().contains(lowerCaseQuery) ||
          game.genres.any((genre) => genre.toLowerCase().contains(lowerCaseQuery)) ||
          game.platforms.any((platform) => platform.toLowerCase().contains(lowerCaseQuery));
    }).toList();
  }

  // Get games by category
  List<Game> getGamesByCategory(GameCategory category) {
    final categoryName = category.toString().split('.').last;
    
    return _games.where((game) {
      return game.genres.any((genre) => 
          genre.toLowerCase() == categoryName.toLowerCase());
    }).toList();
  }

  // Get featured games
  List<Game> getFeaturedGames() {
    return _games.where((game) => game.isFeatured).toList();
  }

  // Get popular games - based on rating and post count
  List<Game> getPopularGames() {
    // Sort by a combination of rating and post count
    final sortedGames = List<Game>.from(_games);
    sortedGames.sort((a, b) {
      // This formula gives a score based on rating and post count
      final scoreA = (a.rating * 0.7) + (a.postCount * 0.01);
      final scoreB = (b.rating * 0.7) + (b.postCount * 0.01);
      return scoreB.compareTo(scoreA); // Descending order
    });
    
    // Return the top 5 games
    return sortedGames.take(5).toList();
  }

  // Get games by genre
  List<Game> getGamesByGenre(String genre) {
    return _games.where((game) => 
      game.genres.any((g) => g.toLowerCase() == genre.toLowerCase())).toList();
  }

  // Reset selected game
  void resetSelectedGame() {
    _selectedGame = null;
    notifyListeners();
  }
}