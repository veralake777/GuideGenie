import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:guide_genie/models/comment.dart';
import 'package:guide_genie/models/post.dart';
import 'package:guide_genie/services/storage_service.dart';

class ApiService {
  static const String baseUrl = 'https://guide-genie-api.example.com/api';
  final StorageService _storageService = StorageService();
  
  // Helper method to get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Helper method to handle API errors
  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      final errorJson = jsonDecode(response.body);
      final errorMessage = errorJson['message'] ?? 'Unknown error occurred';
      throw Exception(errorMessage);
    }
  }
  
  // Authentication APIs
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      _handleError(response);
      return jsonDecode(response.body);
    } catch (e) {
      // Simulate successful login for demo purposes
      await Future.delayed(const Duration(seconds: 1));
      return {
        'token': 'sample_token',
        'user': {
          'id': '1',
          'username': email.split('@')[0],
          'email': email,
          'createdAt': DateTime.now().toIso8601String(),
          'upvotedPosts': [],
          'downvotedPosts': [],
          'upvotedComments': [],
          'downvotedComments': [],
        },
      };
    }
  }
  
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      
      _handleError(response);
      return jsonDecode(response.body);
    } catch (e) {
      // Simulate successful registration for demo purposes
      await Future.delayed(const Duration(seconds: 1));
      return {
        'token': 'sample_token',
        'user': {
          'id': '1',
          'username': username,
          'email': email,
          'createdAt': DateTime.now().toIso8601String(),
          'upvotedPosts': [],
          'downvotedPosts': [],
          'upvotedComments': [],
          'downvotedComments': [],
        },
      };
    }
  }
  
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: headers,
      );
      
      _handleError(response);
      return jsonDecode(response.body);
    } catch (e) {
      // Simulate user data for demo purposes
      await Future.delayed(const Duration(seconds: 1));
      return {
        'id': '1',
        'username': 'demo_user',
        'email': 'demo@example.com',
        'createdAt': DateTime.now().toIso8601String(),
        'upvotedPosts': [],
        'downvotedPosts': [],
        'upvotedComments': [],
        'downvotedComments': [],
      };
    }
  }
  
  // Game APIs
  Future<List<Map<String, dynamic>>> getGames() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/games'));
      
      _handleError(response);
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } catch (e) {
      // Simulate game data for demo purposes
      await Future.delayed(const Duration(seconds: 1));
      
      // Throw error to test default game loading in provider
      throw Exception('Failed to load games: API not available');
    }
  }
  
  // Post APIs
  Future<List<Map<String, dynamic>>> getPostsForGame(String gameId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/games/$gameId/posts'));
      
      _handleError(response);
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } catch (e) {
      // Simulate post data for demo purposes
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'id': '1',
          'gameId': gameId,
          'title': 'Best Character Tier List for Season 3',
          'authorId': '2',
          'authorName': 'ProGamer123',
          'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'content': 'Here\'s my updated tier list for the current season based on competitive play. S Tier: Character X, Character Y. A Tier: Character Z, Character W. B Tier: Character V, Character U. Let me know your thoughts in the comments!',
          'mediaUrls': [],
          'tags': ['Tier List', 'Strategy', 'Competitive'],
          'upvotes': 120,
          'downvotes': 15,
          'commentIds': ['1', '2', '3'],
        },
        {
          'id': '2',
          'gameId': gameId,
          'title': 'Ultimate Beginner\'s Guide',
          'authorId': '3',
          'authorName': 'GameMaster',
          'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'content': 'If you\'re new to the game, this guide will help you get started with the basics. I cover controls, basic strategies, and tips to improve quickly.',
          'mediaUrls': [],
          'tags': ['Beginner', 'Guide', 'Tips'],
          'upvotes': 89,
          'downvotes': 3,
          'commentIds': ['4', '5'],
        },
        {
          'id': '3',
          'gameId': gameId,
          'title': 'Hidden Mechanics You Should Know',
          'authorId': '4',
          'authorName': 'SecretFinder',
          'createdAt': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
          'content': 'After extensive testing, I\'ve discovered some hidden mechanics that aren\'t explained anywhere in the game. These can give you a significant advantage if used correctly.',
          'mediaUrls': [],
          'tags': ['Advanced', 'Mechanics', 'Tips'],
          'upvotes': 45,
          'downvotes': 2,
          'commentIds': [],
        },
        {
          'id': '4',
          'gameId': gameId,
          'title': 'Meta Loadout for Current Season',
          'authorId': '5',
          'authorName': 'LoadoutMaster',
          'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'content': 'This loadout has been dominating in high-level play. Primary: Weapon X with attachments Y and Z. Secondary: Weapon A with attachments B and C. Perks: Perk 1, Perk 2, Perk 3.',
          'mediaUrls': [],
          'tags': ['Loadout', 'Meta', 'Competitive'],
          'upvotes': 76,
          'downvotes': 8,
          'commentIds': ['6'],
        },
      ];
    }
  }
  
  Future<Map<String, dynamic>> createPost(Post post) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: headers,
        body: jsonEncode(post.toJson()),
      );
      
      _handleError(response);
      return jsonDecode(response.body);
    } catch (e) {
      // Simulate post creation for demo purposes
      await Future.delayed(const Duration(seconds: 1));
      return {
        ...post.toJson(),
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      };
    }
  }
  
  Future<void> upvotePost(String postId, String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/upvote'),
        headers: headers,
      );
      
      _handleError(response);
    } catch (e) {
      // Simulate upvote for demo purposes
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
  
  Future<void> downvotePost(String postId, String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/downvote'),
        headers: headers,
      );
      
      _handleError(response);
    } catch (e) {
      // Simulate downvote for demo purposes
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
  
  // Comment APIs
  Future<List<Map<String, dynamic>>> getCommentsForPost(String postId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts/$postId/comments'));
      
      _handleError(response);
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } catch (e) {
      // Simulate comment data for demo purposes
      await Future.delayed(const Duration(seconds: 1));
      return [
        {
          'id': '1',
          'postId': postId,
          'authorId': '5',
          'authorName': 'Commenter1',
          'content': 'This is really helpful, thanks for sharing!',
          'createdAt': DateTime.now().subtract(const Duration(days: 1, hours: 3)).toIso8601String(),
          'upvotes': 12,
          'downvotes': 0,
          'parentCommentId': null,
          'childCommentIds': ['2'],
        },
        {
          'id': '2',
          'postId': postId,
          'authorId': '6',
          'authorName': 'Commenter2',
          'content': 'I agree with this. It\'s definitely the best approach for now.',
          'createdAt': DateTime.now().subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
          'upvotes': 5,
          'downvotes': 1,
          'parentCommentId': '1',
          'childCommentIds': [],
        },
        {
          'id': '3',
          'postId': postId,
          'authorId': '7',
          'authorName': 'Commenter3',
          'content': 'I have to disagree with your tier rankings. Character X should be A tier at best.',
          'createdAt': DateTime.now().subtract(const Duration(hours: 18)).toIso8601String(),
          'upvotes': 3,
          'downvotes': 2,
          'parentCommentId': null,
          'childCommentIds': ['4', '5'],
        },
        {
          'id': '4',
          'postId': postId,
          'authorId': '2',
          'authorName': 'ProGamer123',
          'content': 'Character X has the highest win rate in tournaments right now.',
          'createdAt': DateTime.now().subtract(const Duration(hours: 17)).toIso8601String(),
          'upvotes': 8,
          'downvotes': 0,
          'parentCommentId': '3',
          'childCommentIds': [],
        },
        {
          'id': '5',
          'postId': postId,
          'authorId': '8',
          'authorName': 'GameExpert',
          'content': 'The recent patch actually nerfed Character X, so these rankings might change soon.',
          'createdAt': DateTime.now().subtract(const Duration(hours: 10)).toIso8601String(),
          'upvotes': 6,
          'downvotes': 1,
          'parentCommentId': '3',
          'childCommentIds': [],
        },
      ];
    }
  }
  
  Future<Map<String, dynamic>> createComment(Comment comment) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/comments'),
        headers: headers,
        body: jsonEncode(comment.toJson()),
      );
      
      _handleError(response);
      return jsonDecode(response.body);
    } catch (e) {
      // Simulate comment creation for demo purposes
      await Future.delayed(const Duration(seconds: 1));
      return {
        ...comment.toJson(),
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      };
    }
  }
  
  Future<void> upvoteComment(String commentId, String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/comments/$commentId/upvote'),
        headers: headers,
      );
      
      _handleError(response);
    } catch (e) {
      // Simulate upvote for demo purposes
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
  
  Future<void> downvoteComment(String commentId, String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/comments/$commentId/downvote'),
        headers: headers,
      );
      
      _handleError(response);
    } catch (e) {
      // Simulate downvote for demo purposes
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
  
  // User APIs
  Future<void> updateUser(dynamic updatedUser) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/users/${updatedUser.id}'),
        headers: headers,
        body: jsonEncode(updatedUser.toJson()),
      );
      
      _handleError(response);
    } catch (e) {
      // Simulate update for demo purposes
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
