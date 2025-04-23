import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/services/firebase_service.dart';
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
  // Use late to initialize Firestore later
  late FirebaseFirestore _firestore;
  final RestApiService _apiService = RestApiService();
  
  List<Game> _games = [];
  Game? _selectedGame;
  bool _isLoading = false;
  String? _errorMessage;
  bool _initialized = false;

  // Getters
  List<Game> get games => _games;
  Game? get selectedGame => _selectedGame;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _initialized;
  
  // Constructor without Firestore initialization
  GameProvider();
  
  // Proper initialization method
  Future<void> initialize() async {
    if (_initialized) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Make sure Firebase service is initialized
      if (!FirebaseService.instance.isInitialized) {
        await FirebaseService.instance.initialize();
      }
    
      // Now initialize Firestore
      _firestore = FirebaseFirestore.instance;
      
      // Try to fetch games - this will use the REST API first
      await fetchGames();
      
      // If REST API fetch failed and we have Firestore, try to fetch from Firebase
      if (_games.isEmpty) {
        await _fetchGamesFromFirestore();
      }
      
      // Mark as initialized
      _initialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error initializing GameProvider: $e');
      _errorMessage = 'Failed to initialize: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Private method to fetch games from Firestore
  Future<void> _fetchGamesFromFirestore() async {
    try {
      final gamesSnapshot = await _firestore.collection('games').get();
      
      if (gamesSnapshot.docs.isEmpty) {
        print('No games found in Firestore');
        return;
      }
      
      _games = gamesSnapshot.docs.map((doc) {
        final data = doc.data();
        return Game(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          genre: data['genre'] ?? '',
          rating: (data['rating'] ?? 0).toDouble(),
          postCount: data['postCount'] ?? 0,
          isFeatured: data['isFeatured'] ?? false, 
          iconUrl: '',
          // Add other fields as needed
        );
      }).toList();
      
      print('Loaded ${_games.length} games from Firestore');
    } catch (e) {
      print('Error fetching games from Firestore: $e');
      // Don't rethrow - just log, as this is a fallback method
    }
  }

  // Load/Fetch all games - alias for better naming
  Future<void> loadGames() async {
    if (!_initialized) {
      await initialize();
      return;
    }
    
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
      
      // If REST API fails and we're initialized, try Firestore
      if (_initialized) {
        try {
          await _fetchGamesFromFirestore();
          if (_games.isNotEmpty) {
            _errorMessage = null; // Clear error if we successfully got games from Firestore
          }
        } catch (firestoreError) {
          // Just log this error, we already have an error message from the API
          print('Firestore fallback also failed: $firestoreError');
        }
      }
      
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch game details
  Future<void> fetchGameDetails(String gameId) async {
    if (!_initialized) {
      await initialize();
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final game = await _apiService.getGameById(gameId);
      if (game != null) {
        _selectedGame = game;
      } else {
        // If REST API fails, try Firestore
        if (_initialized) {
          try {
            final docSnapshot = await _firestore.collection('games').doc(gameId).get();
            if (docSnapshot.exists) {
              final data = docSnapshot.data()!;
              _selectedGame = Game(
                id: docSnapshot.id,
                name: data['name'] ?? '',
                description: data['description'] ?? '',
                imageUrl: data['imageUrl'] ?? '',
                genre: data['genre'] ?? '',
                rating: (data['rating'] ?? 0).toDouble(),
                postCount: data['postCount'] ?? 0,
                isFeatured: data['isFeatured'] ?? false, 
                iconUrl: '',
                // Add other fields as needed
              );
            } else {
              _errorMessage = 'Game not found';
            }
          } catch (firestoreError) {
            print('Firestore game fetch failed: $firestoreError');
            _errorMessage = 'Game not found';
          }
        } else {
          _errorMessage = 'Game not found';
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
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
    if (!_initialized) {
      await initialize();
    }
    
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
    if (!_initialized) {
      await initialize();
    }
    
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
      
      // Fallback to local featured games
      return getFeaturedGames();
    }
  }

  // The rest of your methods remain unchanged
  List<Game> getPopularGames() {
    final sortedGames = List<Game>.from(_games);
    sortedGames.sort((a, b) {
      final scoreA = (a.rating * 0.7) + (a.postCount * 0.01);
      final scoreB = (b.rating * 0.7) + (b.postCount * 0.01);
      return scoreB.compareTo(scoreA);
    });
    
    return sortedGames.take(sortedGames.length < 5 ? sortedGames.length : 5).toList();
  }

  List<Game> getGamesByGenre(String genre) {
    return _games.where((game) => 
      game.genre.toLowerCase() == genre.toLowerCase()).toList();
  }

  Future<Game?> createGame(Game game) async {
    if (!_initialized) {
      await initialize();
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdGame = await _apiService.createGame(game);
      
      if (createdGame != null) {
        _games.add(createdGame);
      }
      
      _isLoading = false;
      notifyListeners();
      return createdGame;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Game?> updateGame(Game game) async {
    if (!_initialized) {
      await initialize();
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedGame = await _apiService.updateGame(game);
      
      if (updatedGame != null) {
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
      return null;
    }
  }

  Future<bool> deleteGame(String id) async {
    if (!_initialized) {
      await initialize();
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.deleteGame(id);
      
      if (success) {
        _games.removeWhere((game) => game.id == id);
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void resetSelectedGame() {
    _selectedGame = null;
    notifyListeners();
  }
}