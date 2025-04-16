import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:postgres/postgres.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../models/game.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/guide_post.dart';

class PostgresService {
  static const _defaultDbUrl = 'postgres://postgres:postgres@localhost:5432/guidegenie';
  
  // Private fields
  late String _dbUrl;
  Connection? _connection;
  bool _isConnected = false;
  
  // Flag to determine if we're in web mode with disabled database
  bool _webDatabaseDisabled = false;
  
  // Constructor
  PostgresService() {
    _dbUrl = kIsWeb
        ? Platform.environment['DATABASE_URL'] ?? _defaultDbUrl // Web - use environment var or default
        : Platform.environment['DATABASE_URL'] ?? _defaultDbUrl; // Native - use environment var or default
        
    // For web in development mode, we might want to disable actual DB connections
    if (kIsWeb && kDebugMode) {
      print('PostgresService: Running in web debug mode, checking if DB should be disabled');
      _webDatabaseDisabled = true; // Disable DB in web mode for development
    }
  }
  
  // Initialize the database connection
  Future<void> initialize() async {
    if (_webDatabaseDisabled) {
      print('PostgresService: Database disabled in web mode, using mock data instead');
      return;
    }
    
    try {
      await connect();
      print('PostgresService: Successfully initialized database connection');
    } catch (e) {
      print('PostgresService: Failed to initialize database: $e');
      if (kIsWeb) {
        print('PostgresService: Running in web mode, switching to mock data');
        _webDatabaseDisabled = true;
      } else {
        rethrow;
      }
    }
  }
  
  // Connect to the database
  Future<void> connect() async {
    if (_webDatabaseDisabled) {
      print('PostgresService: Database disabled in web mode, skipping connection');
      return;
    }
    
    if (_isConnected) {
      print('PostgresService: Already connected to database');
      return;
    }
    
    try {
      print('PostgresService: Connecting to database at $_dbUrl');
      _connection = await Connection.open(
        Endpoint(
          host: Uri.parse(_dbUrl).host,
          database: Uri.parse(_dbUrl).pathSegments.last,
          username: Uri.parse(_dbUrl).userInfo.split(':').first,
          password: Uri.parse(_dbUrl).userInfo.split(':').last,
          port: Uri.parse(_dbUrl).port,
        ),
        // Set connection settings
        settings: ConnectionSettings(
          connectTimeout: const Duration(seconds: 10),
          queryTimeout: const Duration(seconds: 30),
          sslMode: SslMode.disable,
        ),
      );
      _isConnected = true;
      print('PostgresService: Successfully connected to database');
    } catch (e) {
      print('PostgresService: Failed to connect to database: $e');
      _isConnected = false;
      rethrow;
    }
  }
  
  // Disconnect from the database
  Future<void> disconnect() async {
    if (_webDatabaseDisabled || !_isConnected || _connection == null) {
      return;
    }
    
    try {
      await _connection!.close();
      _isConnected = false;
      _connection = null;
      print('PostgresService: Disconnected from database');
    } catch (e) {
      print('PostgresService: Error disconnecting from database: $e');
    }
  }
  
  // Execute a database operation within a connection context
  Future<T> _executeDB<T>(
    Future<T> Function(Connection conn) operation,
    {required T defaultValue}
  ) async {
    if (_webDatabaseDisabled) {
      print('PostgresService: Database disabled in web mode, skipping DB operation');
      return defaultValue;
    }
    
    Connection? conn;
    bool localConnection = false;
    
    try {
      // Use existing connection or create a new one
      if (_isConnected && _connection != null) {
        conn = _connection!;
      } else {
        // Create a temporary connection
        conn = await Connection.open(
          Endpoint(
            host: Uri.parse(_dbUrl).host,
            database: Uri.parse(_dbUrl).pathSegments.last,
            username: Uri.parse(_dbUrl).userInfo.split(':').first,
            password: Uri.parse(_dbUrl).userInfo.split(':').last,
            port: Uri.parse(_dbUrl).port,
          ),
          settings: ConnectionSettings(
            connectTimeout: const Duration(seconds: 10),
            queryTimeout: const Duration(seconds: 30),
            sslMode: SslMode.disable,
          ),
        );
        localConnection = true;
      }
      
      // Execute the operation
      final result = await operation(conn);
      
      // Close temporary connection if created
      if (localConnection) {
        await conn.close();
      }
      
      return result;
    } catch (e) {
      print('PostgresService: Error executing database operation: $e');
      
      // Close temporary connection if created
      if (localConnection && conn != null) {
        await conn.close();
      }
      
      return defaultValue;
    }
  }
  
  // User operations
  Future<String> createUser(String username, String email, String password) async {
    final userId = const Uuid().v4();
    final passwordHash = sha256.convert(utf8.encode(password)).toString();
    
    await _executeDB((conn) async {
      await conn.execute(
        'INSERT INTO users (id, username, email, password_hash, bio, avatar_url, reputation, created_at, last_login) '
        'VALUES (@id, @username, @email, @passwordHash, @bio, @avatarUrl, @reputation, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)',
        parameters: {
          'id': userId,
          'username': username,
          'email': email,
          'passwordHash': passwordHash,
          'bio': '',
          'avatarUrl': null,
          'reputation': 0,
        },
      );
    }, defaultValue: '');
    
    return userId;
  }
  
  Future<User?> getUserById(String userId) async {
    return await _executeDB((conn) async {
      final results = await conn.execute(
        'SELECT * FROM users WHERE id = @userId',
        parameters: {'userId': userId},
      );
      
      if (results.isEmpty) {
        return null;
      }
      
      final userData = results.first;
      
      // Get favorite games
      final favoriteResults = await conn.execute(
        'SELECT game_id FROM favorite_games WHERE user_id = @userId',
        parameters: {'userId': userId},
      );
      
      final favoriteGames = favoriteResults.map((row) => row[0] as String).toList();
      
      // Get upvoted posts
      final upvotedPostsResults = await conn.execute(
        'SELECT post_id FROM user_votes '
        'WHERE user_id = @userId AND post_id IS NOT NULL AND is_upvote = TRUE',
        parameters: {'userId': userId},
      );
      
      final upvotedPosts = upvotedPostsResults.map((row) => row[0] as String).toList();
      
      // Get downvoted posts
      final downvotedPostsResults = await conn.execute(
        'SELECT post_id FROM user_votes '
        'WHERE user_id = @userId AND post_id IS NOT NULL AND is_upvote = FALSE',
        parameters: {'userId': userId},
      );
      
      final downvotedPosts = downvotedPostsResults.map((row) => row[0] as String).toList();
      
      // Get upvoted comments
      final upvotedCommentsResults = await conn.execute(
        'SELECT comment_id FROM user_votes '
        'WHERE user_id = @userId AND comment_id IS NOT NULL AND is_upvote = TRUE',
        parameters: {'userId': userId},
      );
      
      final upvotedComments = upvotedCommentsResults.map((row) => row[0] as String).toList();
      
      // Get downvoted comments
      final downvotedCommentsResults = await conn.execute(
        'SELECT comment_id FROM user_votes '
        'WHERE user_id = @userId AND comment_id IS NOT NULL AND is_upvote = FALSE',
        parameters: {'userId': userId},
      );
      
      final downvotedComments = downvotedCommentsResults.map((row) => row[0] as String).toList();
      
      return User(
        id: userData[0] as String,
        username: userData[1] as String,
        email: userData[2] as String,
        bio: userData[4] as String?,
        avatarUrl: userData[5] as String?,
        favoriteGames: favoriteGames,
        upvotedPosts: upvotedPosts,
        downvotedPosts: downvotedPosts,
        upvotedComments: upvotedComments,
        downvotedComments: downvotedComments,
        reputation: userData[6] as int,
        createdAt: userData[7] as DateTime,
        lastLogin: userData[8] as DateTime,
      );
    }, defaultValue: null);
  }
  
  Future<User?> getUserByEmail(String email) async {
    final userId = await _executeDB((conn) async {
      final results = await conn.execute(
        'SELECT id FROM users WHERE email = @email',
        parameters: {'email': email},
      );
      
      if (results.isEmpty) {
        return null;
      }
      
      return results.first[0] as String;
    }, defaultValue: null);
    
    if (userId == null) {
      return null;
    }
    
    return getUserById(userId);
  }
  
  Future<User?> getUserByUsername(String username) async {
    final userId = await _executeDB((conn) async {
      final results = await conn.execute(
        'SELECT id FROM users WHERE username = @username',
        parameters: {'username': username},
      );
      
      if (results.isEmpty) {
        return null;
      }
      
      return results.first[0] as String;
    }, defaultValue: null);
    
    if (userId == null) {
      return null;
    }
    
    return getUserById(userId);
  }
  
  Future<String?> getUserPasswordHash(String email) async {
    return await _executeDB((conn) async {
      final results = await conn.execute(
        'SELECT password_hash FROM users WHERE email = @email',
        parameters: {'email': email},
      );
      
      if (results.isEmpty) {
        return null;
      }
      
      return results.first[0] as String;
    }, defaultValue: null);
  }
  
  Future<void> updateUser(User user) async {
    await _executeDB((conn) async {
      await conn.execute(
        'UPDATE users '
        'SET username = @username, '
        '    email = @email, '
        '    bio = @bio, '
        '    avatar_url = @avatarUrl, '
        '    reputation = @reputation, '
        '    last_login = @lastLogin '
        'WHERE id = @id',
        parameters: {
          'id': user.id,
          'username': user.username,
          'email': user.email,
          'bio': user.bio,
          'avatarUrl': user.avatarUrl,
          'reputation': user.reputation,
          'lastLogin': user.lastLogin.toIso8601String(),
        },
      );
      
      // Update favorite games
      await conn.execute(
        'DELETE FROM favorite_games WHERE user_id = @userId',
        parameters: {'userId': user.id},
      );
      
      for (final gameId in user.favoriteGames) {
        await conn.execute(
          'INSERT INTO favorite_games (user_id, game_id) VALUES (@userId, @gameId)',
          parameters: {
            'userId': user.id,
            'gameId': gameId,
          },
        );
      }
    }, defaultValue: null);
  }
  
  // Game operations
  Future<List<Game>> getAllGames() async {
    // For web development, return mock data
    if (_webDatabaseDisabled) {
      return _getMockGames();
    }
    
    final gameIds = await _executeDB((conn) async {
      final results = await conn.execute('SELECT id FROM games');
      return results.map((row) => row[0] as String).toList();
    }, defaultValue: <String>[]);
    
    final games = <Game>[];
    for (final gameId in gameIds) {
      final game = await getGameById(gameId);
      if (game != null) {
        games.add(game);
      }
    }
    
    return games;
  }
  
  Future<Game?> getGameById(String gameId) async {
    // For web development, return mock game
    if (_webDatabaseDisabled) {
      final mockGame = _getMockGames().firstWhere(
        (game) => game.id == gameId,
        orElse: () => _getMockGames()[0], // Return first mock game as fallback
      );
      return mockGame;
    }
    
    return await _executeDB((conn) async {
      final results = await conn.execute(
        'SELECT * FROM games WHERE id = @gameId',
        parameters: {'gameId': gameId},
      );
      
      if (results.isEmpty) {
        return null;
      }
      
      final gameData = results.first;
      
      // Get platforms
      final platformResults = await conn.execute(
        'SELECT platform FROM game_platforms WHERE game_id = @gameId',
        parameters: {'gameId': gameId},
      );
      
      final platforms = platformResults.map((row) => row[0] as String).toList();
      
      // Get genres
      final genreResults = await conn.execute(
        'SELECT genre FROM game_genres WHERE game_id = @gameId',
        parameters: {'gameId': gameId},
      );
      
      final genres = genreResults.map((row) => row[0] as String).toList();
      
      return Game(
        id: gameData[0] as String,
        title: gameData[1] as String,
        name: gameData[1] as String,
        genre: genres.isNotEmpty ? genres[0] : 'Other',
        imageUrl: gameData[3] as String,
        description: gameData[2] as String,
        coverImageUrl: gameData[3] as String,
        developer: gameData[4] as String,
        publisher: gameData[5] as String,
        releaseDate: gameData[6] as String,
        platforms: platforms,
        genres: genres,
        rating: gameData[7] as double,
        postCount: gameData[8] as int,
        isFeatured: gameData[9] as bool,
      );
    }, defaultValue: null);
  }
  
  Future<List<Game>> getFeaturedGames() async {
    // For web development, return mock featured games
    if (_webDatabaseDisabled) {
      return _getMockGames().where((game) => game.isFeatured).toList();
    }
    
    final gameIds = await _executeDB((conn) async {
      final results = await conn.execute(
        'SELECT id FROM games WHERE is_featured = TRUE'
      );
      return results.map((row) => row[0] as String).toList();
    }, defaultValue: <String>[]);
    
    final games = <Game>[];
    for (final gameId in gameIds) {
      final game = await getGameById(gameId);
      if (game != null) {
        games.add(game);
      }
    }
    
    return games;
  }
  
  // Post operations
  Future<List<Post>> getAllPosts() async {
    // For web development, return mock posts
    if (_webDatabaseDisabled) {
      return _getMockPosts();
    }
    
    final postIds = await _executeDB((conn) async {
      final results = await conn.execute('SELECT id FROM posts');
      return results.map((row) => row[0] as String).toList();
    }, defaultValue: <String>[]);
    
    final posts = <Post>[];
    for (final postId in postIds) {
      final post = await getPostById(postId);
      if (post != null) {
        posts.add(post);
      }
    }
    
    return posts;
  }
  
  Future<Post?> getPostById(String postId) async {
    // For web development, return mock post
    if (_webDatabaseDisabled) {
      final mockPost = _getMockPosts().firstWhere(
        (post) => post.id == postId,
        orElse: () => _getMockPosts()[0], // Return first mock post as fallback
      );
      return mockPost;
    }
    
    return await _executeDB((conn) async {
      final results = await conn.execute(
        'SELECT * FROM posts WHERE id = @postId',
        parameters: {'postId': postId},
      );
      
      if (results.isEmpty) {
        return null;
      }
      
      final postData = results.first;
      
      // Get tags
      final tagResults = await conn.execute(
        'SELECT tag FROM post_tags WHERE post_id = @postId',
        parameters: {'postId': postId},
      );
      
      final tags = tagResults.map((row) => row[0] as String).toList();
      
      return Post(
        id: postData[0] as String,
        title: postData[1] as String,
        content: postData[2] as String,
        gameId: postData[3] as String,
        gameName: postData[4] as String,
        type: postData[5] as String,
        authorId: postData[6] as String,
        authorName: postData[7] as String,
        authorAvatarUrl: postData[8] as String,
        createdAt: postData[9] as DateTime,
        updatedAt: postData[10] as DateTime,
        upvotes: postData[11] as int,
        downvotes: postData[12] as int,
        commentCount: postData[13] as int,
        isFeatured: postData[14] as bool,
        tags: tags,
      );
    }, defaultValue: null);
  }
  
  // Mock data generation for web development
  List<Game> _getMockGames() {
    final games = <Game>[];
    
    // P0 Priority games as per requirements
    games.add(Game(
      id: '1',
      title: 'Fortnite',
      name: 'Fortnite',
      genre: 'Battle Royale',
      imageUrl: 'https://cdn2.unrealengine.com/social-image-chapter4-s3-3840x2160-d35912cc25ad.jpg',
      description: 'A free-to-play Battle Royale game with numerous game modes for every type of player.',
      coverImageUrl: 'https://cdn2.unrealengine.com/social-image-chapter4-s3-3840x2160-d35912cc25ad.jpg',
      developer: 'Epic Games',
      publisher: 'Epic Games',
      releaseDate: '2017-07-25',
      platforms: ['PC', 'PlayStation', 'Xbox', 'Switch', 'Mobile'],
      genres: ['Battle Royale', 'Shooter', 'Survival'],
      rating: 4.8,
      postCount: 145,
      isFeatured: true,
    ));
    
    games.add(Game(
      id: '2',
      title: 'League of Legends',
      name: 'League of Legends',
      genre: 'MOBA',
      imageUrl: 'https://www.leagueoflegends.com/static/open-graph-b580f0266cc3f0589d0dc10765bc1631.jpg',
      description: 'A team-based strategy game where two teams of five champions face off to destroy the other's base.',
      coverImageUrl: 'https://www.leagueoflegends.com/static/open-graph-b580f0266cc3f0589d0dc10765bc1631.jpg',
      developer: 'Riot Games',
      publisher: 'Riot Games',
      releaseDate: '2009-10-27',
      platforms: ['PC'],
      genres: ['MOBA', 'Strategy'],
      rating: 4.6,
      postCount: 212,
      isFeatured: true,
    ));
    
    games.add(Game(
      id: '3',
      title: 'Valorant',
      name: 'Valorant',
      genre: 'Tactical Shooter',
      imageUrl: 'https://cdn.oneesports.gg/cdn-data/2023/06/Valorant_Episode7_Banner.jpg',
      description: 'A 5v5 character-based tactical shooter where precise gunplay meets unique agent abilities.',
      coverImageUrl: 'https://cdn.oneesports.gg/cdn-data/2023/06/Valorant_Episode7_Banner.jpg',
      developer: 'Riot Games',
      publisher: 'Riot Games',
      releaseDate: '2020-06-02',
      platforms: ['PC'],
      genres: ['Tactical Shooter', 'FPS'],
      rating: 4.7,
      postCount: 178,
      isFeatured: true,
    ));
    
    games.add(Game(
      id: '4',
      title: 'Street Fighter 6',
      name: 'Street Fighter 6',
      genre: 'Fighting',
      imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/1364780/header.jpg',
      description: 'The newest entry in the legendary fighting game franchise with new game modes and modern visuals.',
      coverImageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/1364780/header.jpg',
      developer: 'Capcom',
      publisher: 'Capcom',
      releaseDate: '2023-06-02',
      platforms: ['PC', 'PlayStation', 'Xbox'],
      genres: ['Fighting'],
      rating: 4.9,
      postCount: 106,
      isFeatured: true,
    ));
    
    games.add(Game(
      id: '5',
      title: 'Call of Duty',
      name: 'Call of Duty: Modern Warfare III',
      genre: 'FPS',
      imageUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/mw3/home/reveal/mw3-game-banner.jpg',
      description: 'The latest installment in the Call of Duty franchise featuring both multiplayer and campaign modes.',
      coverImageUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/mw3/home/reveal/mw3-game-banner.jpg',
      developer: 'Infinity Ward',
      publisher: 'Activision',
      releaseDate: '2023-11-10',
      platforms: ['PC', 'PlayStation', 'Xbox'],
      genres: ['FPS', 'Action'],
      rating: 4.5,
      postCount: 134,
      isFeatured: true,
    ));
    
    games.add(Game(
      id: '6',
      title: 'Warzone',
      name: 'Call of Duty: Warzone',
      genre: 'Battle Royale',
      imageUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/mw3/home/reveal/mw3-announce-teaser.jpg',
      description: 'A free-to-play battle royale game from the Call of Duty franchise.',
      coverImageUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/mw3/home/reveal/mw3-announce-teaser.jpg',
      developer: 'Infinity Ward, Raven Software',
      publisher: 'Activision',
      releaseDate: '2020-03-10',
      platforms: ['PC', 'PlayStation', 'Xbox'],
      genres: ['Battle Royale', 'FPS'],
      rating: 4.7,
      postCount: 157,
      isFeatured: true,
    ));
    
    games.add(Game(
      id: '7',
      title: 'Marvel Rivals',
      name: 'Marvel Rivals',
      genre: 'Hero Shooter',
      imageUrl: 'https://www.pcgamesn.com/wp-content/sites/pcgamesn/2023/03/marvel-rivals-doctor-strange.jpg',
      description: 'An upcoming team-based third-person hero shooter set in the Marvel universe.',
      coverImageUrl: 'https://www.pcgamesn.com/wp-content/sites/pcgamesn/2023/03/marvel-rivals-doctor-strange.jpg',
      developer: 'NetEase Games',
      publisher: 'Marvel Games',
      releaseDate: '2024',
      platforms: ['PC', 'PlayStation', 'Xbox'],
      genres: ['Hero Shooter', 'Action'],
      rating: 4.4,
      postCount: 58,
      isFeatured: true,
    ));
    
    return games;
  }
  
  List<Post> _getMockPosts() {
    final posts = <Post>[];
    
    posts.add(Post(
      id: '1',
      title: 'Ultimate Fortnite Chapter 5 Weapons Tier List',
      content: '# Fortnite Chapter 5 Weapons Tier List\n\nHere\'s my comprehensive breakdown of the best weapons in the current meta...',
      gameId: '1',
      gameName: 'Fortnite',
      type: 'tier-list',
      authorId: 'user1',
      authorName: 'ProGamer123',
      authorAvatarUrl: 'https://ui-avatars.com/api/?name=Pro+Gamer&background=random',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      upvotes: 324,
      downvotes: 12,
      commentCount: 48,
      isFeatured: true,
      tags: ['weapons', 'tier-list', 'meta', 'chapter-5'],
    ));
    
    posts.add(Post(
      id: '2',
      title: 'Valorant: Complete Agent Selection Guide for Ascent',
      content: '# Agent Selection Guide for Ascent\n\nThis map requires specific agent compositions to maximize win potential...',
      gameId: '3',
      gameName: 'Valorant',
      type: 'guide',
      authorId: 'user2',
      authorName: 'TacticalFPS',
      authorAvatarUrl: 'https://ui-avatars.com/api/?name=Tactical+FPS&background=random',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      upvotes: 411,
      downvotes: 23,
      commentCount: 76,
      isFeatured: true,
      tags: ['agents', 'map-strategy', 'ascent', 'team-comp'],
    ));
    
    posts.add(Post(
      id: '3',
      title: 'Street Fighter 6: Master Ryu\'s Combo List',
      content: '# Ryu Combo Guide\n\nLearn these essential combos to maximize your damage output in every match...',
      gameId: '4',
      gameName: 'Street Fighter 6',
      type: 'guide',
      authorId: 'user3',
      authorName: 'FGCMaster',
      authorAvatarUrl: 'https://ui-avatars.com/api/?name=FGC+Master&background=random',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      upvotes: 289,
      downvotes: 14,
      commentCount: 52,
      isFeatured: true,
      tags: ['ryu', 'combos', 'beginner-friendly', 'frame-data'],
    ));
    
    posts.add(Post(
      id: '4',
      title: 'League of Legends: Current Meta Champions for Each Role',
      content: '# LoL Meta Champion Guide\n\nThe current pro meta favors these champions for each role...',
      gameId: '2',
      gameName: 'League of Legends',
      type: 'tier-list',
      authorId: 'user4',
      authorName: 'RiftStrategy',
      authorAvatarUrl: 'https://ui-avatars.com/api/?name=Rift+Strategy&background=random',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      upvotes: 534,
      downvotes: 41,
      commentCount: 124,
      isFeatured: true,
      tags: ['meta', 'champions', 'roles', 'patch-14.9'],
    ));
    
    posts.add(Post(
      id: '5',
      title: 'Marvel Rivals: All Heroes and Their Ultimate Abilities',
      content: '# Marvel Rivals Hero Guide\n\nComplete breakdown of every hero\'s ultimate ability and how to use it effectively...',
      gameId: '7',
      gameName: 'Marvel Rivals',
      type: 'guide',
      authorId: 'user5',
      authorName: 'MarvelFan',
      authorAvatarUrl: 'https://ui-avatars.com/api/?name=Marvel+Fan&background=random',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      upvotes: 187,
      downvotes: 8,
      commentCount: 35,
      isFeatured: true,
      tags: ['heroes', 'abilities', 'ultimate', 'tier-list'],
    ));
    
    return posts;
  }
  
  // Convert mock posts to guide posts
  List<GuidePost> getMockGuidePosts() {
    final mockPosts = _getMockPosts();
    final guides = <GuidePost>[];
    
    for (final post in mockPosts) {
      guides.add(GuidePost(
        id: post.id,
        title: post.title,
        type: post.type,
        content: post.content,
        gameId: post.gameId,
        gameName: post.gameName,
        authorId: post.authorId,
        authorName: post.authorName,
        authorAvatarUrl: post.authorAvatarUrl,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        likes: post.upvotes,
        commentCount: post.commentCount,
        tags: post.tags,
      ));
    }
    
    return guides;
  }
}