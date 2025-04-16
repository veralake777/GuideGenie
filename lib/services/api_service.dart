import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ApiService {
  // Base URL for the API
  // In a real app, this would point to your actual backend server
  final String baseUrl = 'https://api.example.com';

  // UUID generator for mock responses
  final _uuid = Uuid();

  // Headers for API requests
  Map<String, String> _headers(String? token) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Handle API errors
  Exception _handleError(http.Response response) {
    if (response.statusCode == 401) {
      return Exception('Unauthorized. Please login again.');
    } else if (response.statusCode == 404) {
      return Exception('Resource not found.');
    } else {
      return Exception(
        'API Error: ${response.statusCode} - ${response.reasonPhrase}'
      );
    }
  }

  // For now, this is a mock service that doesn't actually make HTTP requests
  // but simulates API responses for development purposes
  
  // Get all games
  Future<List<Map<String, dynamic>>> getGames() async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(milliseconds: 800));
      
      // In a real app, this would be:
      // final response = await http.get(Uri.parse('$baseUrl/games'));
      // if (response.statusCode == 200) {
      //   return jsonDecode(response.body);
      // } else {
      //   throw _handleError(response);
      // }
      
      // For now, throw an exception to use sample data
      throw Exception('Mock API - using sample data');
    } catch (e) {
      // The provider will handle the exception and use sample data
      throw e;
    }
  }

  // Get game details
  Future<Map<String, dynamic>> getGameDetails(String gameId) async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      
      // In a real app:
      // final response = await http.get(Uri.parse('$baseUrl/games/$gameId'));
      // if (response.statusCode == 200) {
      //   return jsonDecode(response.body);
      // } else {
      //   throw _handleError(response);
      // }
      
      throw Exception('Mock API - using sample data');
    } catch (e) {
      throw e;
    }
  }

  // Get all posts
  Future<List<Map<String, dynamic>>> getPosts() async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      throw Exception('Mock API - using sample data');
    } catch (e) {
      throw e;
    }
  }

  // Get featured posts
  Future<List<Map<String, dynamic>>> getFeaturedPosts() async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      throw Exception('Mock API - using sample data');
    } catch (e) {
      throw e;
    }
  }

  // Get posts by game
  Future<List<Map<String, dynamic>>> getPostsByGame(String gameId) async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      throw Exception('Mock API - using sample data');
    } catch (e) {
      throw e;
    }
  }

  // Get posts by type
  Future<List<Map<String, dynamic>>> getPostsByType(String type) async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      throw Exception('Mock API - using sample data');
    } catch (e) {
      throw e;
    }
  }

  // Get post details
  Future<Map<String, dynamic>> getPostDetails(String postId) async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      throw Exception('Mock API - using sample data');
    } catch (e) {
      throw e;
    }
  }

  // Get comments for a post
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      throw Exception('Mock API - using sample data');
    } catch (e) {
      throw e;
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      
      // For development, simulate a successful login
      final currentTime = DateTime.now();
      return {
        'token': 'mock_jwt_token_${_uuid.v4()}',
        'user': {
          'id': 'user123',
          'username': 'TestUser',
          'email': email,
          'avatarUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
          'bio': 'Gaming enthusiast and guide creator',
          'favoriteGames': ['1', '3', '6'],
          'upvotedPosts': ['1', '3', '9'],
          'downvotedPosts': ['5'],
          'upvotedComments': ['comment1', 'comment2'],
          'downvotedComments': [],
          'reputation': 120,
          'createdAt': currentTime.subtract(Duration(days: 90)).toIso8601String(),
          'lastLogin': currentTime.toIso8601String(),
        }
      };
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Register user
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      
      // For development, simulate a successful registration
      final currentTime = DateTime.now();
      return {
        'token': 'mock_jwt_token_${_uuid.v4()}',
        'user': {
          'id': 'user_${_uuid.v4().substring(0, 8)}',
          'username': username,
          'email': email,
          'avatarUrl': null,
          'bio': null,
          'favoriteGames': [],
          'upvotedPosts': [],
          'downvotedPosts': [],
          'upvotedComments': [],
          'downvotedComments': [],
          'reputation': 0,
          'createdAt': currentTime.toIso8601String(),
          'lastLogin': currentTime.toIso8601String(),
        }
      };
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Create a post
  Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData) async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      
      // For development, simulate a successful post creation
      final currentTime = DateTime.now();
      return {
        'id': 'post_${_uuid.v4().substring(0, 8)}',
        'title': postData['title'],
        'content': postData['content'],
        'authorId': postData['authorId'],
        'authorName': postData['authorName'],
        'authorAvatarUrl': postData['authorAvatarUrl'],
        'gameId': postData['gameId'],
        'gameName': postData['gameName'],
        'type': postData['type'],
        'tags': postData['tags'],
        'upvotes': 0,
        'downvotes': 0,
        'commentCount': 0,
        'createdAt': currentTime.toIso8601String(),
        'updatedAt': currentTime.toIso8601String(),
        'isFeatured': false,
      };
    } catch (e) {
      throw Exception('Failed to create post: ${e.toString()}');
    }
  }

  // Add a comment
  Future<Map<String, dynamic>> addComment(Map<String, dynamic> commentData) async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      
      // For development, simulate a successful comment creation
      final currentTime = DateTime.now();
      return {
        'id': 'comment_${_uuid.v4().substring(0, 8)}',
        'postId': commentData['postId'],
        'content': commentData['content'],
        'authorId': commentData['authorId'],
        'authorName': commentData['authorName'],
        'authorAvatarUrl': commentData['authorAvatarUrl'],
        'upvotes': 0,
        'downvotes': 0,
        'createdAt': currentTime.toIso8601String(),
        'updatedAt': currentTime.toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to add comment: ${e.toString()}');
    }
  }

  // Vote on a post
  Future<void> votePost(String postId, bool isUpvote) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      
      // In a real app, this would make an API call
      // For now, just simulate success
      return;
    } catch (e) {
      throw Exception('Failed to vote on post: ${e.toString()}');
    }
  }

  // Update user data
  Future<void> updateUser(dynamic updatedUser) async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      
      // For now, just simulate success
      return;
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  // Get current user from token
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      
      // For development, simulate a response
      final currentTime = DateTime.now();
      return {
        'id': 'user123',
        'username': 'TestUser',
        'email': 'test@example.com',
        'avatarUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
        'bio': 'Gaming enthusiast and guide creator',
        'favoriteGames': ['1', '3', '6'],
        'upvotedPosts': ['1', '3', '9'],
        'downvotedPosts': ['5'],
        'upvotedComments': ['comment1', 'comment2'],
        'downvotedComments': [],
        'reputation': 120,
        'createdAt': currentTime.subtract(Duration(days: 90)).toIso8601String(),
        'lastLogin': currentTime.toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }
}