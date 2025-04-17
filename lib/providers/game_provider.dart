import 'package:flutter/material.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/services/rest_api_service.dart';

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
  final RestApiService _apiService = RestApiService();
  
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
      _games = await _apiService.getGames();
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
      final game = await _apiService.getGameById(gameId);
      if (game != null) {
        _selectedGame = game;
      } else {
        _errorMessage = 'Game not found';
      }
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
  Future<List<Game>> searchGames(String query) async {
    if (query.isEmpty) return _games;
    
    try {
      return await _apiService.searchGames(query);
    } catch (e) {
      // Fallback to local search if API search fails
      final lowerCaseQuery = query.toLowerCase();
      
      return _games.where((game) {
        return game.name.toLowerCase().contains(lowerCaseQuery) ||
            game.description.toLowerCase().contains(lowerCaseQuery) ||
            game.genre.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    }
  }

  // Get games by category
  List<Game> getGamesByCategory(GameCategory category) {
    final categoryName = category.toString().split('.').last;
    
    return _games.where((game) {
      return game.genre.toLowerCase() == categoryName.toLowerCase();
    }).toList();
  }

  // Get featured games
  List<Game> getFeaturedGames() {
    return _games.where((game) => game.isFeatured).toList();
  }
  
  // Fetch featured games
  Future<List<Game>> fetchFeaturedGames() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final allGames = await _apiService.getGames();
      final featuredGames = allGames.where((game) => game.isFeatured).toList();
      
      // Update local cache with all games
      _games = allGames;
      
      _isLoading = false;
      notifyListeners();
      return featuredGames;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e;
    }
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
    
    // Return the top 5 games, or all if less than 5
    return sortedGames.take(sortedGames.length < 5 ? sortedGames.length : 5).toList();
  }

  // Get games by genre
  List<Game> getGamesByGenre(String genre) {
    return _games.where((game) => 
      game.genre.toLowerCase() == genre.toLowerCase()).toList();
  }

  // Create a new game
  Future<Game?> createGame(Game game) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdGame = await _apiService.createGame(game);
      
      if (createdGame != null) {
        // Add to local cache
        _games.add(createdGame);
      }
      
      _isLoading = false;
      notifyListeners();
      return createdGame;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  // Update a game
  Future<Game?> updateGame(Game game) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedGame = await _apiService.updateGame(game);
      
      if (updatedGame != null) {
        // Update in local cache
        final index = _games.indexWhere((g) => g.id == game.id);
        if (index >= 0) {
          _games[index] = updatedGame;
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return updatedGame;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  // Delete a game
  Future<bool> deleteGame(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.deleteGame(id);
      
      if (success) {
        // Remove from local cache
        _games.removeWhere((game) => game.id == id);
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  // Reset selected game
  void resetSelectedGame() {
    _selectedGame = null;
    notifyListeners();
  }
}