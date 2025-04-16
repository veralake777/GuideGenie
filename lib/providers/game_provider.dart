import 'package:flutter/material.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/services/api_service.dart';

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
    }
  }

  // Search games by query
  List<Game> searchGames(String query) {
    final lowerCaseQuery = query.toLowerCase();
    
    return _games.where((game) {
      return game.name.toLowerCase().contains(lowerCaseQuery) ||
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

  // Reset selected game
  void resetSelectedGame() {
    _selectedGame = null;
    notifyListeners();
  }
}