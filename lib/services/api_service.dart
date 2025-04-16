import 'dart:convert';
import 'dart:math';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/models/post.dart';
import 'package:guide_genie/models/user.dart';
import 'package:guide_genie/utils/constants.dart';
import 'package:uuid/uuid.dart';

// This is a mock API service for development.
// In a real app, this would make HTTP requests to a backend API.
class ApiService {
  // Generate a UUID for IDs
  final Uuid _uuid = const Uuid();
  
  // Simulated user database
  final List<Map<String, dynamic>> _users = [
    {
      'id': 'user-1',
      'username': 'GameMaster',
      'email': 'gamemaster@example.com',
      'bio': 'Professional gamer and guide creator. I love helping others improve their gameplay!',
      'avatarUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
      'favoriteGames': ['game-1', 'game-3'],
      'upvotedPosts': ['post-1', 'post-3'],
      'downvotedPosts': [],
      'upvotedComments': ['comment-1'],
      'downvotedComments': [],
      'reputation': 125,
      'createdAt': '2023-01-15T10:30:00Z',
      'lastLogin': '2023-05-01T14:22:00Z',
    },
    {
      'id': 'user-2',
      'username': 'StrategyQueen',
      'email': 'strategyqueen@example.com',
      'bio': 'Strategy game enthusiast. I create detailed guides for beginners and advanced players.',
      'avatarUrl': 'https://randomuser.me/api/portraits/women/2.jpg',
      'favoriteGames': ['game-2', 'game-4'],
      'upvotedPosts': ['post-2'],
      'downvotedPosts': ['post-4'],
      'upvotedComments': [],
      'downvotedComments': ['comment-2'],
      'reputation': 84,
      'createdAt': '2023-02-10T16:45:00Z',
      'lastLogin': '2023-04-28T09:12:00Z',
    },
  ];
  
  // Simulated game database
  final List<Map<String, dynamic>> _games = [
    {
      'id': 'game-1',
      'name': 'Fortnite',
      'description': 'Fortnite is a popular battle royale game developed by Epic Games. Players compete individually or as a team to be the last standing on a shrinking island filled with weapons and resources.',
      'coverImageUrl': 'https://cdn2.unrealengine.com/25br-s25-egs-launcher-pdp-2560x1440-2560x1440-6f0e3e5e9078.jpg',
      'developer': 'Epic Games',
      'publisher': 'Epic Games',
      'releaseDate': '2017-07-25',
      'platforms': ['PC', 'PlayStation', 'Xbox', 'Nintendo Switch', 'Mobile'],
      'genres': ['Battle Royale', 'Shooter', 'Action'],
      'rating': 4.5,
      'postCount': 15,
      'isFeatured': true,
    },
    {
      'id': 'game-2',
      'name': 'League of Legends',
      'description': 'League of Legends is a team-based strategy game where two teams of five powerful champions face off to destroy the other\'s base. Choose from over 140 champions to make epic plays, secure kills, and take down towers.',
      'coverImageUrl': 'https://cdn1.epicgames.com/offer/24b9b5e323bc40eea252a10cdd3b2f10/EGS_LeagueofLegends_RiotGames_S1_2560x1440-80471666c140f790f28dff68d72c384b',
      'developer': 'Riot Games',
      'publisher': 'Riot Games',
      'releaseDate': '2009-10-27',
      'platforms': ['PC', 'Mac'],
      'genres': ['MOBA', 'Strategy'],
      'rating': 4.3,
      'postCount': 22,
      'isFeatured': true,
    },
    {
      'id': 'game-3',
      'name': 'Valorant',
      'description': 'Valorant is a free-to-play first-person tactical shooter developed and published by Riot Games. The game operates on an economy-round, objective-based, first-to-13 competitive format.',
      'coverImageUrl': 'https://media.wired.com/photos/5eab5dc40cd8a3fff5cd88c2/master/pass/Culture_Valorant_Riot-Games-Beta.jpg',
      'developer': 'Riot Games',
      'publisher': 'Riot Games',
      'releaseDate': '2020-06-02',
      'platforms': ['PC'],
      'genres': ['Tactical Shooter', 'FPS'],
      'rating': 4.4,
      'postCount': 18,
      'isFeatured': false,
    },
    {
      'id': 'game-4',
      'name': 'Street Fighter 6',
      'description': 'Street Fighter 6 is a fighting game developed and published by Capcom. It is the seventh main installment in the Street Fighter series and features a roster of returning and new characters.',
      'coverImageUrl': 'https://cdn.cloudflare.steamstatic.com/steam/apps/1364780/header.jpg',
      'developer': 'Capcom',
      'publisher': 'Capcom',
      'releaseDate': '2023-06-02',
      'platforms': ['PC', 'PlayStation', 'Xbox'],
      'genres': ['Fighting'],
      'rating': 4.7,
      'postCount': 8,
      'isFeatured': true,
    },
    {
      'id': 'game-5',
      'name': 'Call of Duty: Modern Warfare III',
      'description': 'Call of Duty: Modern Warfare III is a first-person shooter game developed by Infinity Ward and published by Activision. It is the twentieth installment in the Call of Duty series.',
      'coverImageUrl': 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/blog/hero/mwiii/MWIII-REVEAL-FULL-TOUT.jpg',
      'developer': 'Infinity Ward',
      'publisher': 'Activision',
      'releaseDate': '2023-11-10',
      'platforms': ['PC', 'PlayStation', 'Xbox'],
      'genres': ['FPS', 'Action'],
      'rating': 4.2,
      'postCount': 12,
      'isFeatured': false,
    },
    {
      'id': 'game-6',
      'name': 'Warzone',
      'description': 'Call of Duty: Warzone is a free-to-play battle royale game that is a part of the Call of Duty franchise. Players compete to be the last team standing in a massive battlefield.',
      'coverImageUrl': 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/blog/hero/warzone/WZ-Season-Three-Announce-TOUT.jpg',
      'developer': 'Infinity Ward, Raven Software',
      'publisher': 'Activision',
      'releaseDate': '2020-03-10',
      'platforms': ['PC', 'PlayStation', 'Xbox'],
      'genres': ['Battle Royale', 'FPS'],
      'rating': 4.1,
      'postCount': 20,
      'isFeatured': false,
    },
    {
      'id': 'game-7',
      'name': 'Marvel Rivals',
      'description': 'Marvel Rivals is a superhero-based team shooter game featuring iconic Marvel characters. Players can choose from a variety of heroes and villains, each with unique abilities.',
      'coverImageUrl': 'https://cdn1.epicgames.com/offer/1eea99c0a93a494ea563e144eb455a80/EGS_DisneySpeedstormStandardFoundersPack_GameloftBarcelona_Editions_S2_1200x1600-28afa910d53dd0dff08e56c6b58a0fb4?h=480&quality=medium&resize=1&w=360',
      'developer': 'NetEase Games',
      'publisher': 'NetEase Games',
      'releaseDate': '2024-01-15',
      'platforms': ['PC', 'PlayStation', 'Xbox', 'Mobile'],
      'genres': ['Hero Shooter', 'Action'],
      'rating': 4.6,
      'postCount': 5,
      'isFeatured': true,
    },
  ];
  
  // Simulated post database
  final List<Map<String, dynamic>> _posts = [
    {
      'id': 'post-1',
      'title': 'Ultimate Fortnite Chapter 5 Strategy Guide',
      'content': 'This comprehensive guide will help you master the mechanics of Fortnite Chapter 5. We cover building techniques, weapon strategies, and map knowledge to help you secure Victory Royales consistently.\n\nStart by landing at less populated areas to gather resources before engaging. Focus on mastering basic building techniques like the wall-ramp push and box fighting. Always carry a balanced loadout with weapons for different ranges. Pay attention to the storm circle and position yourself strategically as the game progresses.',
      'gameId': 'game-1',
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
      'gameId': 'game-2',
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
      'id': 'post-3',
      'title': 'Valorant Agent Mastery: Jett Guide',
      'content': 'Master Jett\'s abilities and become a force to be reckoned with in Valorant. This guide covers movement mechanics, ability usage, and optimal weapon choices for this duelist.\n\nJett\'s primary strength lies in her mobility. Use Updraft to access unexpected angles and Tailwind to quickly reposition after taking shots. Practice using her Cloudburst smokes to create brief concealment for aggressive plays. Her Blade Storm ultimate is extremely powerful for eco rounds and can be devastating in the hands of a skilled player. Pair Jett with precise weapons like the Operator or Vandal to maximize her peek-and-retreat playstyle.',
      'gameId': 'game-3',
      'gameName': 'Valorant',
      'type': 'advancedTips',
      'tags': ['jett', 'agent guide', 'duelist', 'abilities'],
      'authorId': 'user-1',
      'authorName': 'GameMaster',
      'authorAvatarUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
      'createdAt': '2023-05-10T16:45:00Z',
      'updatedAt': '2023-05-10T16:45:00Z',
      'upvotes': 56,
      'downvotes': 4,
      'commentCount': 15,
      'isFeatured': false,
    },
    {
      'id': 'post-4',
      'title': 'Street Fighter 6 Best Combos for Ryu',
      'content': 'Learn the most powerful and consistent Ryu combos in Street Fighter 6. This guide includes combo notations, damage values, and execution tips.\n\nBasic Combo: Medium Punch > Medium Kick > Hadouken (236P)\nBNB Combo: Medium Punch > Medium Kick > Heavy Tatsu (214K) > Shoryuken (623P)\nCorner Combo: Jump Heavy Kick > Medium Punch > Medium Kick > Heavy Tatsu > Critical Art\n\nPractice these combos in training mode until you can execute them consistently. Focus on your timing, especially for the Shoryuken input which requires precision.',
      'gameId': 'game-4',
      'gameName': 'Street Fighter 6',
      'type': 'loadout',
      'tags': ['ryu', 'combos', 'fundamentals'],
      'authorId': 'user-2',
      'authorName': 'StrategyQueen',
      'authorAvatarUrl': 'https://randomuser.me/api/portraits/women/2.jpg',
      'createdAt': '2023-06-10T13:20:00Z',
      'updatedAt': '2023-06-12T09:15:00Z',
      'upvotes': 35,
      'downvotes': 2,
      'commentCount': 8,
      'isFeatured': false,
    },
    {
      'id': 'post-5',
      'title': 'Call of Duty: Modern Warfare III Weapon Meta Analysis',
      'content': 'Dive deep into the current weapon meta of MW3 with statistical analysis and practical recommendations. We cover the best weapons for different playstyles and maps.\n\nAssault Rifles: The M4A1 continues to dominate due to its consistent damage profile and manageable recoil. The AK-47 is a close second with higher damage but more challenging recoil patterns.\n\nSMGs: The MP5 remains the king of close-quarters combat with excellent TTK and mobility. The P90 offers a larger magazine and better range at the cost of raw DPS.\n\nSniper Rifles: The Intervention provides the best one-shot kill potential, while the HDR offers better bullet velocity for longer distances.',
      'gameId': 'game-5',
      'gameName': 'Call of Duty: Modern Warfare III',
      'type': 'metaAnalysis',
      'tags': ['weapons', 'meta', 'statistics', 'loadouts'],
      'authorId': 'user-1',
      'authorName': 'GameMaster',
      'authorAvatarUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
      'createdAt': '2023-11-20T11:30:00Z',
      'updatedAt': '2023-11-25T14:45:00Z',
      'upvotes': 92,
      'downvotes': 7,
      'commentCount': 31,
      'isFeatured': true,
    },
    {
      'id': 'post-6',
      'title': 'Warzone Season 2 Map Guide: All New POIs',
      'content': 'Explore the new points of interest in Warzone Season 2 with this comprehensive map guide. Learn the best landing spots, loot routes, and strategic positions.\n\nThe new map features several key POIs:\n\n1. Harbor District: High-tier loot but heavily contested\n2. Power Station: Medium-tier loot with excellent positioning for mid-game\n3. Abandoned Mall: Complex interior with multiple levels and plenty of cover\n4. Underground Bunkers: Limited access points but contains special loot crates\n\nWe recommend newer players start with less-contested areas like the Residential Zone until they get comfortable with the game mechanics.',
      'gameId': 'game-6',
      'gameName': 'Warzone',
      'type': 'strategy',
      'tags': ['season 2', 'map guide', 'POIs', 'landing spots'],
      'authorId': 'user-2',
      'authorName': 'StrategyQueen',
      'authorAvatarUrl': 'https://randomuser.me/api/portraits/women/2.jpg',
      'createdAt': '2023-02-25T10:20:00Z',
      'updatedAt': '2023-02-28T15:10:00Z',
      'upvotes': 68,
      'downvotes': 5,
      'commentCount': 19,
      'isFeatured': false,
    },
    {
      'id': 'post-7',
      'title': 'Marvel Rivals: Complete Beginner\'s Guide',
      'content': 'Welcome to Marvel Rivals! This guide covers all the basics new players need to know, from hero selection to team composition and basic gameplay mechanics.\n\nMarvel Rivals is a 6v6 team-based shooter where each hero has unique abilities and roles. The game features objective-based game modes where coordination is key to victory.\n\nFor beginners, we recommend starting with more straightforward heroes like Captain America (Tank), Iron Man (Damage), or Doctor Strange (Support). Focus on learning one hero from each category to be flexible in team compositions.\n\nObjectives should always take priority over eliminations. Work with your team to capture points, escort payloads, or complete the map-specific objectives.',
      'gameId': 'game-7',
      'gameName': 'Marvel Rivals',
      'type': 'beginnerTips',
      'tags': ['beginner guide', 'heroes', 'basics', 'team composition'],
      'authorId': 'user-1',
      'authorName': 'GameMaster',
      'authorAvatarUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
      'createdAt': '2024-01-20T08:45:00Z',
      'updatedAt': '2024-01-22T11:30:00Z',
      'upvotes': 43,
      'downvotes': 2,
      'commentCount': 14,
      'isFeatured': true,
    },
  ];
  
  // Simulated comments database
  final List<Map<String, dynamic>> _comments = [
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
      'postId': 'post-3',
      'content': 'Great Jett guide! Could you add some info about her synergy with other agents like Omen or Brimstone?',
      'authorId': 'user-2',
      'authorName': 'StrategyQueen',
      'authorAvatarUrl': 'https://randomuser.me/api/portraits/women/2.jpg',
      'createdAt': '2023-05-11T11:40:00Z',
      'upvotes': 3,
      'downvotes': 0,
    },
    {
      'id': 'comment-4',
      'postId': 'post-7',
      'content': 'Thanks for the beginner guide! I\'m new to hero shooters, so this was really helpful. Could you explain more about team synergies?',
      'authorId': 'user-2',
      'authorName': 'StrategyQueen',
      'authorAvatarUrl': 'https://randomuser.me/api/portraits/women/2.jpg',
      'createdAt': '2024-01-21T16:30:00Z',
      'upvotes': 2,
      'downvotes': 0,
    },
  ];

  // API Methods

  // User methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Find user by email (in a real app, we would check password too)
    final user = _users.firstWhere(
      (u) => u['email'] == email,
      orElse: () => throw Exception('Invalid email or password'),
    );
    
    return {
      'token': 'mock_jwt_token_${_uuid.v4()}',
      'user': user,
    };
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Check if email already exists
    if (_users.any((u) => u['email'] == email)) {
      throw Exception('Email already in use');
    }
    
    // Check if username already exists
    if (_users.any((u) => u['username'] == username)) {
      throw Exception('Username already taken');
    }
    
    // Create new user
    final now = DateTime.now().toIso8601String();
    final userId = 'user-${_users.length + 1}';
    
    final newUser = {
      'id': userId,
      'username': username,
      'email': email,
      'bio': null,
      'avatarUrl': null,
      'favoriteGames': <String>[],
      'upvotedPosts': <String>[],
      'downvotedPosts': <String>[],
      'upvotedComments': <String>[],
      'downvotedComments': <String>[],
      'reputation': 0,
      'createdAt': now,
      'lastLogin': now,
    };
    
    // Add to database
    _users.add(newUser);
    
    return {
      'token': 'mock_jwt_token_${_uuid.v4()}',
      'user': newUser,
    };
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // In a real app, we would use the token to get the current user
    // For mock purposes, just return the first user
    return _users.first;
  }

  Future<void> updateUser(Map<String, dynamic> userData) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Find user by ID
    final index = _users.indexWhere((u) => u['id'] == userData['id']);
    if (index == -1) {
      throw Exception('User not found');
    }
    
    // Update user data
    _users[index] = {
      ..._users[index],
      ...userData,
    };
  }

  // Game methods
  Future<List<Map<String, dynamic>>> getGames() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));
    
    return _games;
  }

  Future<Map<String, dynamic>> getGameDetails(String gameId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Find game by ID
    final game = _games.firstWhere(
      (g) => g['id'] == gameId,
      orElse: () => throw Exception('Game not found'),
    );
    
    return game;
  }

  // Post methods
  Future<List<Map<String, dynamic>>> getPosts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    return _posts;
  }

  Future<List<Map<String, dynamic>>> getFeaturedPosts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Filter posts by featured
    return _posts.where((p) => p['isFeatured'] == true).toList();
  }

  Future<List<Map<String, dynamic>>> getLatestPosts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));
    
    // Sort posts by date (newest first) and take first 10
    final sortedPosts = List<Map<String, dynamic>>.from(_posts)
      ..sort((a, b) => DateTime.parse(b['createdAt'])
          .compareTo(DateTime.parse(a['createdAt'])));
    
    return sortedPosts.take(10).toList();
  }

  Future<List<Map<String, dynamic>>> getPostsByGame(String gameId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Filter posts by game ID
    return _posts.where((p) => p['gameId'] == gameId).toList();
  }

  Future<Map<String, dynamic>> getPostDetails(String postId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Find post by ID
    final post = _posts.firstWhere(
      (p) => p['id'] == postId,
      orElse: () => throw Exception('Post not found'),
    );
    
    return post;
  }

  Future<void> createPost(Map<String, dynamic> postData) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Generate a new ID
    final postId = 'post-${_posts.length + 1}';
    
    // Add the new post
    _posts.add({
      ...postData,
      'id': postId,
      'isFeatured': false,
    });
    
    // Update game post count
    final gameIndex = _games.indexWhere((g) => g['id'] == postData['gameId']);
    if (gameIndex != -1) {
      _games[gameIndex] = {
        ..._games[gameIndex],
        'postCount': _games[gameIndex]['postCount'] + 1,
      };
    }
  }

  // Comment methods
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Filter comments by post ID
    return _comments.where((c) => c['postId'] == postId).toList();
  }

  Future<void> createComment(Map<String, dynamic> commentData) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Generate a new ID
    final commentId = 'comment-${_comments.length + 1}';
    
    // Add the new comment
    _comments.add({
      ...commentData,
      'id': commentId,
    });
    
    // Update post comment count
    final postIndex = _posts.indexWhere((p) => p['id'] == commentData['postId']);
    if (postIndex != -1) {
      _posts[postIndex] = {
        ..._posts[postIndex],
        'commentCount': _posts[postIndex]['commentCount'] + 1,
      };
    }
  }

  // Voting methods
  Future<void> votePost(String postId, bool isUpvote) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find post by ID
    final postIndex = _posts.indexWhere((p) => p['id'] == postId);
    if (postIndex == -1) {
      throw Exception('Post not found');
    }
    
    // Update vote count
    _posts[postIndex] = {
      ..._posts[postIndex],
      'upvotes': isUpvote
          ? _posts[postIndex]['upvotes'] + 1
          : _posts[postIndex]['upvotes'],
      'downvotes': !isUpvote
          ? _posts[postIndex]['downvotes'] + 1
          : _posts[postIndex]['downvotes'],
    };
  }

  Future<void> voteComment(String commentId, bool isUpvote) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Find comment by ID
    final commentIndex = _comments.indexWhere((c) => c['id'] == commentId);
    if (commentIndex == -1) {
      throw Exception('Comment not found');
    }
    
    // Update vote count
    _comments[commentIndex] = {
      ..._comments[commentIndex],
      'upvotes': isUpvote
          ? _comments[commentIndex]['upvotes'] + 1
          : _comments[commentIndex]['upvotes'],
      'downvotes': !isUpvote
          ? _comments[commentIndex]['downvotes'] + 1
          : _comments[commentIndex]['downvotes'],
    };
  }
}