import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/services/http_client.dart';

class RestApiService {
  // Get all games
  Future<List<Map<String, dynamic>>> getGames() async {
    try {
      final response = await ApiClient.get('games');
      
      if (response is List) {
        return response.map((json) => json as Map<String, dynamic>).toList();
      } else {
        throw Exception('Unexpected response format for games');
      }
    } catch (e) {
      print('Error fetching games: $e');
      return [];
    }
  }
  
  // Get game by ID
  Future<Map<String, dynamic>?> getGameById(String id) async {
    try {
      final response = await ApiClient.get('games/$id');
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching game by ID: $e');
      return null;
    }
  }
  
  // Create new game
  Future<Map<String, dynamic>?> createGame(Map<String, dynamic> gameData) async {
    try {
      final response = await ApiClient.post('games', gameData);
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error creating game: $e');
      return null;
    }
  }
  
  // Update game
  Future<Map<String, dynamic>?> updateGame(String id, Map<String, dynamic> gameData) async {
    try {
      final response = await ApiClient.put('games/$id', gameData);
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error updating game: $e');
      return null;
    }
  }
  
  // Delete game
  Future<bool> deleteGame(String id) async {
    try {
      await ApiClient.delete('games/$id');
      return true;
    } catch (e) {
      print('Error deleting game: $e');
      return false;
    }
  }
  
  // Convert API response to Game object
  Game? convertToGame(Map<String, dynamic>? json) {
    if (json == null) return null;
    
    return Game(
      id: json['id']?.toString() ?? '',
      title: json['name'] ?? '',
      genre: json['description'] ?? '',
      imageUrl: json['icon_url'] ?? '',
      rating: 0.0, // Rating might not be in the API response
      description: json['description'] ?? '',
      developer: '',
      publisher: '',
      isFeatured: json['status'] == 'active',
    );
  }
  
  // Convert Game object to API request format
  Map<String, dynamic> convertFromGame(Game game) {
    return {
      'name': game.title,
      'description': game.description,
      'icon_url': game.imageUrl,
      'status': game.isFeatured ? 'active' : 'inactive',
    };
  }
}