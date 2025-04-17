import 'dart:convert';
import 'dart:math';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/models/guide_post.dart';
import 'package:guide_genie/models/user.dart';
import 'package:guide_genie/services/database_service.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';

// This service handles API requests and database operations.
// It uses DatabaseService for data access.
class ApiService {
  // Generate a UUID for IDs
  final Uuid _uuid = const Uuid();
  
  // Database service
  final DatabaseService _db = DatabaseService();
  
  // Get all games
  Future<List<Map<String, dynamic>>> getGames() async {
    final games = await _db.getAllGames();
    return games.map((game) => {
      'id': game.id,
      'title': game.title,
      'genre': game.genre,
      'imageUrl': game.imageUrl,
      'rating': game.rating,
      'description': game.description,
    }).toList();
  }
  
  // Get featured games
  Future<List<Map<String, dynamic>>> getFeaturedGames() async {
    final games = await _db.getFeaturedGames();
    return games.map((game) => {
      'id': game.id,
      'title': game.title,
      'genre': game.genre,
      'imageUrl': game.imageUrl,
      'rating': game.rating,
      'description': game.description,
      'isFeatured': true,
    }).toList();
  }
  
  // Get popular games (highest rated)
  Future<List<Map<String, dynamic>>> getPopularGames() async {
    final games = await _db.getPopularGames();
    return games.map((game) => {
      'id': game.id,
      'title': game.title,
      'genre': game.genre,
      'imageUrl': game.imageUrl,
      'rating': game.rating,
      'description': game.description,
    }).toList();
  }
  
  // Get game details by ID
  Future<Map<String, dynamic>> getGameDetails(String id) async {
    final game = await _db.getGameById(id);
    if (game == null) {
      throw Exception('Game not found');
    }
    
    return {
      'id': game.id,
      'title': game.title,
      'genre': game.genre,
      'imageUrl': game.imageUrl,
      'rating': game.rating,
      'description': game.description,
    };
  }
  
  // Get all posts
  Future<List<Map<String, dynamic>>> getPosts() async {
    // For now, we'll use mock data for posts
    return _getMockPosts();
  }
  
  // Get featured posts
  Future<List<Map<String, dynamic>>> getFeaturedPosts() async {
    final posts = _getMockPosts();
    return posts.where((post) => post['isFeatured'] == true).toList();
  }
  
  // Get latest posts
  Future<List<Map<String, dynamic>>> getLatestPosts() async {
    final posts = _getMockPosts();
    posts.sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
    return posts.take(5).toList();
  }
  
  // Get posts by game
  Future<List<Map<String, dynamic>>> getPostsByGame(String gameId) async {
    final posts = _getMockPosts();
    return posts.where((post) => post['gameId'] == gameId).toList();
  }
  
  // Get post details by ID
  Future<Map<String, dynamic>> getPostDetails(String id) async {
    final posts = _getMockPosts();
    final post = posts.firstWhere(
      (post) => post['id'] == id,
      orElse: () => throw Exception('Post not found'),
    );
    return post;
  }
  
  // Get comments for a post
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    final comments = _getMockComments();
    return comments.where((comment) => comment['postId'] == postId).toList();
  }
  
  // Create a new post
  Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData) async {
    // In a real application, this would save to the database
    final post = {
      'id': 'post-${_uuid.v4().substring(0, 8)}',
      ...postData,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'upvotes': 0,
      'downvotes': 0,
      'commentCount': 0,
      'isFeatured': false,
    };
    
    return post;
  }
  
  // Create a new comment
  Future<Map<String, dynamic>> createComment(Map<String, dynamic> commentData) async {
    // In a real application, this would save to the database
    final comment = {
      'id': 'comment-${_uuid.v4().substring(0, 8)}',
      ...commentData,
      'createdAt': DateTime.now().toIso8601String(),
      'upvotes': 0,
      'downvotes': 0,
    };
    
    return comment;
  }
  
  // Vote on a post (upvote or downvote)
  Future<void> votePost(String postId, bool isUpvote) async {
    // In a real application, this would update the database
    print('Voted ${isUpvote ? 'up' : 'down'} on post $postId');
  }
  
  // User registration
  Future<Map<String, dynamic>> registerUser(String username, String email, String password) async {
    // In a real application, this would create a user in the database
    // Here we just return a mock user
    final now = DateTime.now().toIso8601String();
    final salt = _generateSalt();
    final passwordHash = _hashPassword(password, salt);
    
    final user = {
      'id': 'user-${_uuid.v4().substring(0, 8)}',
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'salt': salt,
      'createdAt': now,
      'updatedAt': now,
      'avatarUrl': 'https://randomuser.me/api/portraits/lego/1.jpg',
    };
    
    return {
      'id': user['id'],
      'username': user['username'],
      'email': user['email'],
      'avatarUrl': user['avatarUrl'],
      'token': _generateToken(user['id'] as String),
    };
  }
  
  // User login
  Future<Map<String, dynamic>> login(String email, String password) async {
    // In a real application, this would verify credentials against the database
    // Here we just return a mock user if the email contains "user"
    if (email.contains('user')) {
      final userId = 'user-${_uuid.v4().substring(0, 8)}';
      return {
        'id': userId,
        'username': email.split('@')[0],
        'email': email,
        'avatarUrl': 'https://randomuser.me/api/portraits/lego/1.jpg',
        'token': _generateToken(userId),
      };
    } else {
      throw Exception('Invalid credentials');
    }
  }
  
  // Helper methods
  String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }
  
  String _hashPassword(String password, String salt) {
    final key = utf8.encode(password);
    final saltBytes = base64Decode(salt);
    final hmac = Hmac(sha256, saltBytes);
    final digest = hmac.convert(key);
    return digest.toString();
  }
  
  String _generateToken(String userId) {
    final payload = {
      'sub': userId,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000,
    };
    return base64Encode(utf8.encode(json.encode(payload)));
  }
  
  // Mock data methods
  List<Map<String, dynamic>> _getMockPosts() {
    return [
      {
        'id': 'post-1',
        'title': 'Ultimate Fortnite Chapter 5 Strategy Guide',
        'content': 'This comprehensive guide will help you master the mechanics of Fortnite Chapter 5. We cover building techniques, weapon strategies, and map knowledge to help you secure Victory Royales consistently.\n\nStart by landing at less populated areas to gather resources before engaging. Focus on mastering basic building techniques like the wall-ramp push and box fighting. Always carry a balanced loadout with weapons for different ranges. Pay attention to the storm circle and position yourself strategically as the game progresses.',
        'gameId': '1',
        'gameName': 'Fortnite',
        'type': 'strategy',
        'tags': ['beginner', 'chapter 5', 'building', 'strategy'],
        'authorId': 'user-1',
        'authorName': 'GameMaster',
        'authorAvatarUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
        'createdAt': '2023-03-15T14:30:00Z',
        'updatedAt': '2023-03-15T14:30:00Z',
        'upvotes': 42,
        'downvotes': 3,
        'commentCount': 7,
        'isFeatured': true,
      },
      {
        'id': 'post-2',
        'title': 'League of Legends S13 Champion Tier List',
        'content': 'Here\'s the comprehensive tier list for League of Legends Season 13. We analyze the current meta and rank champions based on their performance in different roles.\n\nS-Tier (Top Lane): Darius, Sett, Fiora\nS-Tier (Jungle): Vi, Hecarim, Warwick\nS-Tier (Mid Lane): Ahri, Viktor, Syndra\nS-Tier (Bot Lane): Jinx, Jhin, Kai\'Sa\nS-Tier (Support): Leona, Nautilus, Thresh\n\nThese champions excel in the current meta due to their strong kit, favorable item builds, and synergy with common team compositions.',
        'gameId': '2',
        'gameName': 'League of Legends',
        'type': 'tierList',
        'tags': ['tier list', 'season 13', 'meta', 'champions'],
        'authorId': 'user-2',
        'authorName': 'StrategyQueen',
        'authorAvatarUrl': 'https://randomuser.me/api/portraits/women/2.jpg',
        'createdAt': '2023-04-02T09:15:00Z',
        'updatedAt': '2023-04-05T11:20:00Z',
        'upvotes': 78,
        'downvotes': 12,
        'commentCount': 23,
        'isFeatured': true,
      },
      {
        'id': 'post-5',
        'title': 'Ultimate Fortnite Season X Weapon Tier List',
        'content': 'Check out the latest tier rankings for all weapons in Season X! This guide breaks down each weapon by its damage, rarity, and situational effectiveness.',
        'gameId': '1',
        'gameName': 'Fortnite',
        'type': 'Tier List',
        'tags': ['weapon', 'tier-list', 'meta', 'season-x'],
        'authorId': 'user1',
        'authorName': 'JohnDoe',
        'authorAvatarUrl': 'https://i.pravatar.cc/150?img=11',
        'createdAt': '2023-11-20T11:30:00Z',
        'updatedAt': '2023-11-25T14:45:00Z',
        'upvotes': 245,
        'downvotes': 7,
        'commentCount': 38,
        'isFeatured': true,
      },
    ];
  }
  
  List<Map<String, dynamic>> _getMockComments() {
    return [
      {
        'id': 'comment-1',
        'postId': 'post-1',
        'content': 'This guide really helped me improve my building techniques! I\'ve already seen a big difference in my gameplay.',
        'authorId': 'user-2',
        'authorName': 'StrategyQueen',
        'authorAvatarUrl': 'https://randomuser.me/api/portraits/women/2.jpg',
        'createdAt': '2023-03-16T09:20:00Z',
        'upvotes': 5,
        'downvotes': 0,
      },
      {
        'id': 'comment-2',
        'postId': 'post-2',
        'content': 'I disagree with Ahri being S-tier. She\'s strong but definitely more of an A-tier pick right now due to the recent nerfs.',
        'authorId': 'user-1',
        'authorName': 'GameMaster',
        'authorAvatarUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
        'createdAt': '2023-04-03T14:15:00Z',
        'upvotes': 8,
        'downvotes': 3,
      },
      {
        'id': 'comment-3',
        'postId': 'post-5',
        'content': 'This tier list is spot on! I\'ve been dominating with the Combat Shotgun lately.',
        'authorId': 'user-3',
        'authorName': 'Alex Thompson',
        'authorAvatarUrl': 'https://randomuser.me/api/portraits/men/3.jpg',
        'createdAt': '2023-11-21T16:30:00Z',
        'upvotes': 42,
        'downvotes': 0,
      },
      {
        'id': 'comment-4',
        'postId': 'post-5',
        'content': 'I think the Burst AR should be higher tier. It\'s really effective if you can master it!',
        'authorId': 'user-4',
        'authorName': 'Sarah J.',
        'authorAvatarUrl': 'https://randomuser.me/api/portraits/women/4.jpg',
        'createdAt': '2023-11-22T09:45:00Z',
        'upvotes': 28,
        'downvotes': 2,
      },
      {
        'id': 'comment-5',
        'postId': 'post-5',
        'content': 'Great list! What about the new items that were just added?',
        'authorId': 'user-5',
        'authorName': 'GamerPro99',
        'authorAvatarUrl': 'https://randomuser.me/api/portraits/men/5.jpg',
        'createdAt': '2023-11-23T14:20:00Z',
        'upvotes': 15,
        'downvotes': 0,
      },
    ];
  }
}