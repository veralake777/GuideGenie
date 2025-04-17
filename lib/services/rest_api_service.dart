import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/services/firestore_service.dart';
import 'package:guide_genie/services/http_client.dart';

class RestApiService {
  final FirestoreService _firestoreService = FirestoreService();
  
  // Get all games - Using Firebase
  Future<List<Game>> getGames() async {
    try {
      // First try to get from Firestore
      final games = await _firestoreService.getAllGames();
      if (games.isNotEmpty) {
        return games;
      }
      
      // Fallback to API
      final response = await ApiClient.get('games');
      
      if (response is List) {
        List<Map<String, dynamic>> jsonList = 
            response.map((json) => json as Map<String, dynamic>).toList();
        
        return jsonList.map((json) => Game.fromMap({
          'id': json['id']?.toString() ?? '',
          'name': json['name'] ?? '',
          'description': json['description'] ?? '',
          'iconUrl': json['icon_url'] ?? '',
          'status': json['status'] ?? 'active',
          'isFeatured': json['status'] == 'active',
        })).toList();
      } else {
        throw Exception('Unexpected response format for games');
      }
    } catch (e) {
      print('Error fetching games: $e');
      return [];
    }
  }
  
  // Get game by ID - Using Firebase
  Future<Game?> getGameById(String id) async {
    try {
      // First try to get from Firestore
      final game = await _firestoreService.getGameById(id);
      if (game != null) {
        return game;
      }
      
      // Fallback to API
      final response = await ApiClient.get('games/$id');
      if (response is Map<String, dynamic>) {
        return Game.fromMap({
          'id': response['id']?.toString() ?? '',
          'name': response['name'] ?? '',
          'description': response['description'] ?? '',
          'iconUrl': response['icon_url'] ?? '',
          'status': response['status'] ?? 'active',
          'isFeatured': response['status'] == 'active',
        });
      }
      return null;
    } catch (e) {
      print('Error fetching game by ID: $e');
      return null;
    }
  }
  
  // Create new game - Using Firebase
  Future<Game?> createGame(Game game) async {
    try {
      // Save to Firestore
      final createdGame = await _firestoreService.createGame(game);
      
      // Also save to API for backward compatibility
      final gameData = {
        'name': game.name,
        'description': game.description,
        'icon_url': game.iconUrl,
        'status': game.isFeatured ? 'active' : 'inactive',
      };
      
      await ApiClient.post('games', gameData);
      
      return createdGame;
    } catch (e) {
      print('Error creating game: $e');
      return null;
    }
  }
  
  // Update game - Using Firebase
  Future<Game?> updateGame(Game game) async {
    try {
      // Update in Firestore
      final updatedGame = await _firestoreService.updateGame(game);
      
      // Also update in API for backward compatibility
      final gameData = {
        'name': game.name,
        'description': game.description,
        'icon_url': game.iconUrl,
        'status': game.isFeatured ? 'active' : 'inactive',
      };
      
      await ApiClient.put('games/${game.id}', gameData);
      
      return updatedGame;
    } catch (e) {
      print('Error updating game: $e');
      return null;
    }
  }
  
  // Delete game - Using Firebase
  Future<bool> deleteGame(String id) async {
    try {
      // Delete from Firestore
      final success = await _firestoreService.deleteGame(id);
      
      // Also delete from API for backward compatibility
      await ApiClient.delete('games/$id');
      
      return success;
    } catch (e) {
      print('Error deleting game: $e');
      return false;
    }
  }
  
  // Search games - Using Firebase
  Future<List<Game>> searchGames(String query) async {
    try {
      return await _firestoreService.searchGames(query);
    } catch (e) {
      print('Error searching games: $e');
      return [];
    }
  }
}