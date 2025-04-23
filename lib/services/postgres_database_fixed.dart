import 'dart:async';
import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/models/post.dart';
import 'package:guide_genie/models/user.dart';
import 'package:guide_genie/models/comment.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class PostgresDatabase {
  static final PostgresDatabase _instance = PostgresDatabase._internal();
  factory PostgresDatabase() => _instance;
  
  PostgresDatabase._internal();
  
  Connection? _connection;
  bool _isConnected = false;
  bool _webDatabaseDisabled = false;
  
  // Mock data for development/preview in web mode
  List<Game> _getMockGames() {
    return [
      Game(
        id: 'fortnite',
        name: 'Fortnite',
        title: 'Fortnite',
        description: 'A battle royale game with building mechanics.',
        imageUrl: 'assets/game_logos/fortnite.png',
        coverImageUrl: 'assets/game_logos/fortnite.png',
        developer: 'Epic Games',
        publisher: 'Epic Games',
        releaseDate: '2017-07-25',
        platforms: ['PC', 'PlayStation', 'Xbox', 'Switch', 'Mobile'],
        genres: ['Battle Royale', 'Shooter', 'Survival'],
        rating: 4.5,
        postCount: 15,
        isFeatured: true,
        genre: 'Battle Royale',
      ),
      Game(
        id: 'league-of-legends',
        name: 'League of Legends',
        title: 'League of Legends',
        description: 'A MOBA game with over 150 champions.',
        imageUrl: 'assets/game_logos/league_of_legends.png',
        coverImageUrl: 'assets/game_logos/league_of_legends.png',
        developer: 'Riot Games',
        publisher: 'Riot Games',
        releaseDate: '2009-10-27',
        platforms: ['PC'],
        genres: ['MOBA', 'Strategy'],
        rating: 4.3,
        postCount: 22,
        isFeatured: true,
        genre: 'MOBA',
      ),
      Game(
        id: 'valorant',
        name: 'Valorant',
        title: 'Valorant',
        description: 'A tactical shooter with unique character abilities.',
        imageUrl: 'assets/game_logos/valorant.png',
        coverImageUrl: 'assets/game_logos/valorant.png',
        developer: 'Riot Games',
        publisher: 'Riot Games',
        releaseDate: '2020-06-02',
        platforms: ['PC'],
        genres: ['Tactical Shooter', 'FPS'],
        rating: 4.2,
        postCount: 18,
        isFeatured: true,
        genre: 'Tactical Shooter',
      ),
    ];
  }
  
  // Helper method to safely execute database operations
  Future<dynamic> _executeDB(
    Future<dynamic> Function(Connection conn) dbOperation, 
    {dynamic defaultValue}
  ) async {
    await connect();
    
    if (_webDatabaseDisabled) {
      print('PostgresDatabase: Web database disabled, skipping DB operation');
      return defaultValue;
    }
    
    if (_connection == null) {
      print('PostgresDatabase: Connection is null, cannot execute operation');
      return defaultValue;
    }
    
    try {
      return await dbOperation(_connection!);
    } catch (e) {
      print('PostgresDatabase: Error executing operation: $e');
      return defaultValue;
    }
  }
  
  Future<void> connect() async {
    if (_isConnected) return;
    
    print('PostgresDatabase: Attempting to connect to database...');
    
    try {
      // Load .env file
      await dotenv.load();
      
      // Check if database should be disabled in web mode
      if (kIsWeb) {
        final disableDb = dotenv.env['DISABLE_DATABASE_IN_WEB'];
        if (disableDb == 'true') {
          print('PostgresDatabase: Database connections are disabled in web mode. Using mock data.');
          _webDatabaseDisabled = true;
          _isConnected = true; // Pretend we're connected to avoid errors
          return;
        }
      }
      
      // Variables for connection
      String? databaseUrl;
      String? pgUser;
      String? pgPassword;
      String? pgHost;
      String? pgDatabase;
      String? pgPort;
      
      // First try .env file which works in all environments
      try {
        databaseUrl = dotenv.env['DATABASE_URL'];
        if (databaseUrl != null && databaseUrl.isNotEmpty) {
          print('PostgresDatabase: Found DATABASE_URL in .env file');
        }
      } catch (e) {
        print('PostgresDatabase: Error getting DATABASE_URL from .env: $e');
      }
      
      // Next try to get Postgres environment variables directly
      try {
        pgUser = const String.fromEnvironment('PGUSER');
        pgPassword = const String.fromEnvironment('PGPASSWORD');
        pgHost = const String.fromEnvironment('PGHOST');
        pgDatabase = const String.fromEnvironment('PGDATABASE');
        pgPort = const String.fromEnvironment('PGPORT');
      } catch (e) {
        print('PostgresDatabase: Error getting PG environment variables: $e');
      }
      
      // If environment variables are not set, try to get them from dotenv
      if (pgHost == null || pgHost.isEmpty) {
        pgHost = dotenv.env['LOCAL_DATABASE_HOST'];
        pgUser = dotenv.env['LOCAL_DATABASE_USER'];
        pgPassword = dotenv.env['LOCAL_DATABASE_PASSWORD'];
        pgDatabase = dotenv.env['LOCAL_DATABASE_NAME'];
        pgPort = dotenv.env['LOCAL_DATABASE_PORT'];
        print('PostgresDatabase: Using database values from dotenv file');
      }
      
      if (pgHost != null && pgHost.isNotEmpty) {
        print('PostgresDatabase: Using direct PostgreSQL environment variables');
        print('PostgresDatabase: Host: $pgHost, DB: $pgDatabase, User: $pgUser');
        
        final endpoint = Endpoint(
          host: pgHost,
          port: int.tryParse(pgPort ?? '') ?? 5432,
          database: pgDatabase ?? 'postgres',
          username: pgUser ?? 'postgres',
          password: pgPassword ?? '',
        );
        
        _connection = await Connection.open(endpoint);
      } 
      // If direct variables not available, try using DATABASE_URL
      else if (databaseUrl != null && databaseUrl.isNotEmpty) {
        print('PostgresDatabase: Connecting using DATABASE_URL...');
        
        final uri = Uri.parse(databaseUrl);
        final userInfo = uri.userInfo.split(':');
        final username = userInfo[0];
        final password = userInfo.length > 1 ? userInfo[1] : '';
        final database = uri.path.replaceFirst('/', '');
        
        print('PostgresDatabase: Parsed DATABASE_URL - Host: ${uri.host}, Port: ${uri.port}, DB: $database, User: $username');
        
        final endpoint = Endpoint(
          host: uri.host,
          port: uri.port,
          database: database,
          username: username,
          password: password,
        );
        
        _connection = await Connection.open(endpoint);
      } 
      // Fallback to default development values as last resort
      else {
        print('PostgresDatabase: No database connection info found, using fallback parameters...');
        const host = 'localhost'; 
        const port = 5432;
        const database = 'postgres';
        const username = 'postgres';
        const password = '';
        
        print('PostgresDatabase: Using fallback connection details - Host: $host, Port: $port, DB: $database, User: $username');
        
        final endpoint = Endpoint(
          host: host,
          port: port, 
          database: database,
          username: username,
          password: password,
        );
        
        _connection = await Connection.open(endpoint);
      }
      
      _isConnected = true;
      print('PostgresDatabase: Connection established successfully');
      
      await _createTables();
      print('PostgresDatabase: Tables created/verified');
      
      // Check if seed data needs to be inserted
      final games = await getAllGames();
      print('PostgresDatabase: Found ${games.length} games in database');
      
      if (games.isEmpty) {
        print('PostgresDatabase: No games found, seeding database with initial data...');
        await _seedData();
      } else {
        print('PostgresDatabase: Data already exists, skipping seed');
      }
    } catch (e) {
      print('PostgreSQL connection error: $e');
      print('PostgreSQL connection error stack trace: ${StackTrace.current}');
      
      // For web development, switch to mock data mode
      if (kIsWeb) {
        print('PostgresDatabase: Connection failed in web mode, switching to mock data');
        _webDatabaseDisabled = true;
        _isConnected = true; // Pretend we're connected
      } else {
        rethrow;
      }
    }
  }
  
  Future<void> close() async {
    if (_isConnected && _connection != null && !_webDatabaseDisabled) {
      await _connection!.close();
      _isConnected = false;
    }
  }
  
  Future<void> _createTables() async {
    // Skip in web mode if disabled
    if (_webDatabaseDisabled) return;
    
    await _executeDB((conn) async {
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id TEXT PRIMARY KEY,
          username TEXT NOT NULL UNIQUE,
          email TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          bio TEXT,
          avatar_url TEXT,
          reputation INTEGER NOT NULL DEFAULT 0,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          last_login TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS favorite_games (
          user_id TEXT,
          game_id TEXT,
          PRIMARY KEY (user_id, game_id),
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS games (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          cover_image_url TEXT NOT NULL,
          developer TEXT NOT NULL,
          publisher TEXT NOT NULL,
          release_date TEXT NOT NULL,
          rating REAL NOT NULL,
          post_count INTEGER NOT NULL DEFAULT 0,
          is_featured BOOLEAN NOT NULL DEFAULT FALSE
        )
      ''');
      
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS game_platforms (
          game_id TEXT,
          platform TEXT,
          PRIMARY KEY (game_id, platform),
          FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE
        )
      ''');
      
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS game_genres (
          game_id TEXT,
          genre TEXT,
          PRIMARY KEY (game_id, genre),
          FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE
        )
      ''');
      
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS posts (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          game_id TEXT NOT NULL,
          game_name TEXT NOT NULL,
          type TEXT NOT NULL,
          author_id TEXT NOT NULL,
          author_name TEXT NOT NULL,
          author_avatar_url TEXT NOT NULL,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          upvotes INTEGER NOT NULL DEFAULT 0,
          downvotes INTEGER NOT NULL DEFAULT 0,
          comment_count INTEGER NOT NULL DEFAULT 0,
          is_featured BOOLEAN NOT NULL DEFAULT FALSE,
          FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE,
          FOREIGN KEY (author_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS post_tags (
          post_id TEXT,
          tag TEXT,
          PRIMARY KEY (post_id, tag),
          FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE
        )
      ''');
      
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS comments (
          id TEXT PRIMARY KEY,
          post_id TEXT NOT NULL,
          content TEXT NOT NULL,
          author_id TEXT NOT NULL,
          author_name TEXT NOT NULL,
          author_avatar_url TEXT NOT NULL,
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
          upvotes INTEGER NOT NULL DEFAULT 0,
          downvotes INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE,
          FOREIGN KEY (author_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS user_votes (
          user_id TEXT,
          post_id TEXT,
          comment_id TEXT,
          is_upvote BOOLEAN NOT NULL,
          PRIMARY KEY (user_id, COALESCE(post_id, ''), COALESCE(comment_id, '')),
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE,
          FOREIGN KEY (comment_id) REFERENCES comments (id) ON DELETE CASCADE,
          CHECK (
            (post_id IS NOT NULL AND comment_id IS NULL) OR
            (post_id IS NULL AND comment_id IS NOT NULL)
          )
        )
      ''');
    });
  }
  
  // User operations
  Future<void> createUser(User user, String passwordHash) async {
    await _executeDB((conn) async {
      await conn.execute(
        Sql.named('''
          INSERT INTO users (id, username, email, password_hash, bio, avatar_url, reputation)
          VALUES (@id, @username, @email, @passwordHash, @bio, @avatarUrl, @reputation)
        '''),
        parameters: {
          'id': user.id,
          'username': user.username,
          'email': user.email,
          'passwordHash': passwordHash,
          'bio': user.bio,
          'avatarUrl': user.avatarUrl,
          'reputation': user.reputation,
        },
      );
      
      // Insert favorite games
      for (final gameId in user.favoriteGames) {
        await conn.execute(
          Sql.named('''
            INSERT INTO favorite_games (user_id, game_id)
            VALUES (@userId, @gameId)
          '''),
          parameters: {
            'userId': user.id,
            'gameId': gameId,
          },
        );
      }
    });
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
        Sql.named('SELECT game_id FROM favorite_games WHERE user_id = @userId'),
        parameters: {'userId': userId},
      );
      
      final favoriteGames = favoriteResults.map((row) => row[0] as String).toList();
      
      // Get upvoted posts
      final upvotedPostsResults = await conn.execute(
        Sql.named('''
          SELECT post_id FROM user_votes
          WHERE user_id = @userId AND post_id IS NOT NULL AND is_upvote = TRUE
        '''),
        parameters: {'userId': userId},
      );
      
      final upvotedPosts = upvotedPostsResults.map((row) => row[0] as String).toList();
      
      // Get downvoted posts
      final downvotedPostsResults = await conn.execute(
        Sql.named('''
          SELECT post_id FROM user_votes
          WHERE user_id = @userId AND post_id IS NOT NULL AND is_upvote = FALSE
        '''),
        parameters: {'userId': userId},
      );
      
      final downvotedPosts = downvotedPostsResults.map((row) => row[0] as String).toList();
      
      // Get upvoted comments
      final upvotedCommentsResults = await conn.execute(
        Sql.named('''
          SELECT comment_id FROM user_votes
          WHERE user_id = @userId AND comment_id IS NOT NULL AND is_upvote = TRUE
        '''),
        parameters: {'userId': userId},
      );
      
      final upvotedComments = upvotedCommentsResults.map((row) => row[0] as String).toList();
      
      // Get downvoted comments
      final downvotedCommentsResults = await conn.execute(
        Sql.named('''
          SELECT comment_id FROM user_votes
          WHERE user_id = @userId AND comment_id IS NOT NULL AND is_upvote = FALSE
        '''),
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
        Sql.named('SELECT id FROM users WHERE email = @email'),
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
        Sql.named('SELECT id FROM users WHERE username = @username'),
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
  
  Future<List<User>> getAllUsers() async {
    final userIds = await _executeDB((conn) async {
      final results = await conn.execute('SELECT id FROM users');
      return results.map((row) => row[0] as String).toList();
    }, defaultValue: <String>[]);
    
    final users = <User>[];
    for (final userId in userIds) {
      final user = await getUserById(userId);
      if (user != null) {
        users.add(user);
      }
    }
    
    return users;
  }
  
  Future<String?> getUserPasswordHash(String email) async {
    return await _executeDB((conn) async {
      final results = await conn.execute(
        Sql.named('SELECT password_hash FROM users WHERE email = @email'),
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
        Sql.named('''
          UPDATE users
          SET username = @username,
              email = @email,
              bio = @bio,
              avatar_url = @avatarUrl,
              reputation = @reputation,
              last_login = @lastLogin
          WHERE id = @id
        '''),
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
        Sql.named('DELETE FROM favorite_games WHERE user_id = @userId'),
        parameters: {'userId': user.id},
      );
      
      for (final gameId in user.favoriteGames) {
        await conn.execute(
          Sql.named('INSERT INTO favorite_games (user_id, game_id) VALUES (@userId, @gameId)'),
          parameters: {
            'userId': user.id,
            'gameId': gameId,
          },
        );
      }
    });
  }
  
  Future<void> updateUserLastLogin(String userId) async {
    await _executeDB((conn) async {
      await conn.execute(
        Sql.named('''
          UPDATE users
          SET last_login = CURRENT_TIMESTAMP
          WHERE id = @id
        '''),
        parameters: {'id': userId},
      );
    });
  }
  
  Future<void> updateUserPassword(String userId, String passwordHash) async {
    await _executeDB((conn) async {
      await conn.execute(
        Sql.named('''
          UPDATE users
          SET password_hash = @passwordHash
          WHERE id = @id
        '''),
        parameters: {
          'id': userId,
          'passwordHash': passwordHash,
        },
      );
    });
  }
  
  // Game operations
  Future<void> createGame(Game game) async {
    await _executeDB((conn) async {
      await conn.execute(
        Sql.named('''
          INSERT INTO games (
            id, name, description, cover_image_url, developer, publisher,
            release_date, rating, post_count, is_featured
          )
          VALUES (
            @id, @name, @description, @coverImageUrl, @developer, @publisher,
            @releaseDate, @rating, @postCount, @isFeatured
          )
        '''),
        parameters: {
          'id': game.id,
          'name': game.name,
          'description': game.description,
          'coverImageUrl': game.coverImageUrl,
          'developer': game.developer,
          'publisher': game.publisher,
          'releaseDate': game.releaseDate,
          'rating': game.rating,
          'postCount': game.postCount,
          'isFeatured': game.isFeatured,
        },
      );
      
      // Insert platforms
      for (final platform in game.platforms) {
        await conn.execute(
          Sql.named('''
            INSERT INTO game_platforms (game_id, platform)
            VALUES (@gameId, @platform)
          '''),
          parameters: {
            'gameId': game.id,
            'platform': platform,
          },
        );
      }
      
      // Insert genres
      for (final genre in game.genres) {
        await conn.execute(
          Sql.named('''
            INSERT INTO game_genres (game_id, genre)
            VALUES (@gameId, @genre)
          '''),
          parameters: {
            'gameId': game.id,
            'genre': genre,
          },
        );
      }
    });
  }
  
  Future<Game?> getGameById(String gameId) async {
    // For web mode with disabled DB, return game from mock data
    if (_webDatabaseDisabled) {
      final mockGame = _getMockGames().firstWhere(
        (game) => game.id == gameId,
        orElse: () => _getMockGames()[0], // Return first mock game as fallback
      );
      print('PostgresDatabase: Web database disabled, returning mock game for ID: $gameId');
      return mockGame;
    }
    
    return await _executeDB((conn) async {
      final results = await conn.execute(
        Sql.named('SELECT * FROM games WHERE id = @gameId'),
        parameters: {'gameId': gameId},
      );
      
      if (results.isEmpty) {
        return null;
      }
      
      final gameData = results.first;
      
      // Get platforms
      final platformResults = await conn.execute(
        Sql.named('SELECT platform FROM game_platforms WHERE game_id = @gameId'),
        parameters: {'gameId': gameId},
      );
      
      final platforms = platformResults.map((row) => row[0] as String).toList();
      
      // Get genres
      final genreResults = await conn.execute(
        Sql.named('SELECT genre FROM game_genres WHERE game_id = @gameId'),
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
  
  Future<List<Game>> getAllGames() async {
    // Return mock data in web mode if database is disabled
    if (_webDatabaseDisabled) {
      print('PostgresDatabase: Web database disabled, returning mock games');
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
  
  Future<List<Game>> getFeaturedGames() async {
    // Return featured mock games in web mode if database is disabled
    if (_webDatabaseDisabled) {
      print('PostgresDatabase: Web database disabled, returning mock featured games');
      return _getMockGames().where((game) => game.isFeatured).toList();
    }
    
    final gameIds = await _executeDB((conn) async {
      final results = await conn.execute(
        Sql.named('SELECT id FROM games WHERE is_featured = TRUE')
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
  
  Future<void> updateGamePostCount(String gameId, int count) async {
    await _executeDB((conn) async {
      await conn.execute(
        Sql.named('''
          UPDATE games
          SET post_count = @count
          WHERE id = @id
        '''),
        parameters: {
          'id': gameId,
          'count': count,
        },
      );
    });
  }
  
  // Post operations
  Future<void> createPost(Post post) async {
    await _executeDB((conn) async {
      await conn.execute(
        Sql.named('''
          INSERT INTO posts (
            id, title, content, game_id, game_name, type, author_id,
            author_name, author_avatar_url, created_at, updated_at,
            upvotes, downvotes, comment_count, is_featured
          )
          VALUES (
            @id, @title, @content, @gameId, @gameName, @type, @authorId,
            @authorName, @authorAvatarUrl, @createdAt, @updatedAt,
            @upvotes, @downvotes, @commentCount, @isFeatured
          )
        '''),
        parameters: {
          'id': post.id,
          'title': post.title,
          'content': post.content,
          'gameId': post.gameId,
          'gameName': post.gameName,
          'type': post.type,
          'authorId': post.authorId,
          'authorName': post.authorName,
          'authorAvatarUrl': post.authorAvatarUrl,
          'createdAt': post.createdAt.toIso8601String(),
          'updatedAt': post.updatedAt.toIso8601String(),
          'upvotes': post.upvotes,
          'downvotes': post.downvotes,
          'commentCount': post.commentCount,
          'isFeatured': post.isFeatured,
        },
      );
      
      // Insert tags
      for (final tag in post.tags) {
        await conn.execute(
          Sql.named('INSERT INTO post_tags (post_id, tag) VALUES (@postId, @tag)'),
          parameters: {
            'postId': post.id,
            'tag': tag,
          },
        );
      }
    });
    
    // Update game post count
    final game = await getGameById(post.gameId);
    if (game != null) {
      await updateGamePostCount(post.gameId, game.postCount + 1);
    }
  }
  
  Future<Post?> getPostById(String postId) async {
    return await _executeDB((conn) async {
      final results = await conn.execute(
        Sql.named('SELECT * FROM posts WHERE id = @postId'),
        parameters: {'postId': postId},
      );
      
      if (results.isEmpty) {
        return null;
      }
      
      final postData = results.first;
      
      // Get tags
      final tagResults = await conn.execute(
        Sql.named('SELECT tag FROM post_tags WHERE post_id = @postId'),
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
  
  Future<List<Post>> getAllPosts() async {
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
  
  Future<List<Post>> getFeaturedPosts() async {
    final postIds = await _executeDB((conn) async {
      final results = await conn.execute(
        Sql.named('SELECT id FROM posts WHERE is_featured = TRUE')
      );
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
  
  Future<List<Post>> getLatestPosts(int limit) async {
    final postIds = await _executeDB((conn) async {
      final results = await conn.execute(
        Sql.named('SELECT id FROM posts ORDER BY created_at DESC LIMIT @limit'),
        parameters: {'limit': limit},
      );
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
  
  Future<List<Post>> getPostsByGame(String gameId) async {
    final postIds = await _executeDB((conn) async {
      final results = await conn.execute(
        Sql.named('SELECT id FROM posts WHERE game_id = @gameId'),
        parameters: {'gameId': gameId},
      );
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
  
  Future<List<Post>> getPostsByUser(String userId) async {
    final postIds = await _executeDB((conn) async {
      final results = await conn.execute(
        Sql.named('SELECT id FROM posts WHERE author_id = @userId'),
        parameters: {'userId': userId},
      );
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
  
  Future<void> updatePostVotes(String postId, int upvotes, int downvotes) async {
    await _executeDB((conn) async {
      await conn.execute(
        Sql.named('''
          UPDATE posts
          SET upvotes = @upvotes, downvotes = @downvotes
          WHERE id = @id
        '''),
        parameters: {
          'id': postId,
          'upvotes': upvotes,
          'downvotes': downvotes,
        },
      );
    });
  }
  
  Future<void> updatePostCommentCount(String postId, int count) async {
    await _executeDB((conn) async {
      await conn.execute(
        Sql.named('''
          UPDATE posts
          SET comment_count = @count
          WHERE id = @id
        '''),
        parameters: {
          'id': postId,
          'count': count,
        },
      );
    });
  }
  
  // Comment operations
  Future<void> createComment(Comment comment) async {
    await _executeDB((conn) async {
      await conn.execute(
        Sql.named('''
          INSERT INTO comments (
            id, post_id, content, author_id, author_name,
            author_avatar_url, created_at, upvotes, downvotes
          )
          VALUES (
            @id, @postId, @content, @authorId, @authorName,
            @authorAvatarUrl, @createdAt, @upvotes, @downvotes
          )
        '''),
        parameters: {
          'id': comment.id,
          'postId': comment.postId,
          'content': comment.content,
          'authorId': comment.authorId,
          'authorName': comment.authorName,
          'authorAvatarUrl': comment.authorAvatarUrl,
          'createdAt': comment.createdAt.toIso8601String(),
          'upvotes': comment.upvotes,
          'downvotes': comment.downvotes,
        },
      );
    });
    
    // Update post comment count
    final post = await getPostById(comment.postId);
    if (post != null) {
      await updatePostCommentCount(comment.postId, post.commentCount + 1);
    }
  }
  
  Future<List<Comment>> getCommentsByPost(String postId) async {
    return await _executeDB((conn) async {
      final results = await conn.execute(
        Sql.named('''
          SELECT * FROM comments
          WHERE post_id = @postId
          ORDER BY created_at DESC
        '''),
        parameters: {'postId': postId},
      );
      
      return results.map((row) {
        return Comment(
          id: row[0] as String,
          postId: row[1] as String,
          content: row[2] as String,
          authorId: row[3] as String,
          authorName: row[4] as String,
          authorAvatarUrl: row[5] as String,
          createdAt: row[6] as DateTime,
          upvotes: row[7] as int,
          downvotes: row[8] as int,
        );
      }).toList();
    }, defaultValue: <Comment>[]);
  }
  
  Future<void> updateCommentVotes(String commentId, int upvotes, int downvotes) async {
    await _executeDB((conn) async {
      await conn.execute(
        Sql.named('''
          UPDATE comments
          SET upvotes = @upvotes, downvotes = @downvotes
          WHERE id = @id
        '''),
        parameters: {
          'id': commentId,
          'upvotes': upvotes,
          'downvotes': downvotes,
        },
      );
    });
  }
  
  // Vote operations
  Future<void> saveVote(
    String userId,
    String? postId,
    String? commentId,
    bool isUpvote,
  ) async {
    assert(postId != null || commentId != null);
    assert(!(postId != null && commentId != null));
    
    await _executeDB((conn) async {
      // Delete existing vote if any
      if (postId != null) {
        await conn.execute(
          Sql.named('''
            DELETE FROM user_votes
            WHERE user_id = @userId AND post_id = @postId
          '''),
          parameters: {
            'userId': userId,
            'postId': postId,
          },
        );
      } else if (commentId != null) {
        await conn.execute(
          Sql.named('''
            DELETE FROM user_votes
            WHERE user_id = @userId AND comment_id = @commentId
          '''),
          parameters: {
            'userId': userId,
            'commentId': commentId,
          },
        );
      }
      
      // Insert new vote
      await conn.execute(
        Sql.named('''
          INSERT INTO user_votes (user_id, post_id, comment_id, is_upvote)
          VALUES (@userId, @postId, @commentId, @isUpvote)
        '''),
        parameters: {
          'userId': userId,
          'postId': postId,
          'commentId': commentId,
          'isUpvote': isUpvote,
        },
      );
    });
    
    // Update vote count
    if (postId != null) {
      final post = await getPostById(postId);
      if (post != null) {
        final upvotes = isUpvote ? post.upvotes + 1 : post.upvotes;
        final downvotes = !isUpvote ? post.downvotes + 1 : post.downvotes;
        await updatePostVotes(postId, upvotes, downvotes);
      }
    } else if (commentId != null) {
      final comment = await _executeDB((conn) async {
        final commentResults = await conn.execute(
          Sql.named('SELECT upvotes, downvotes FROM comments WHERE id = @commentId'),
          parameters: {'commentId': commentId},
        );
        
        if (commentResults.isEmpty) {
          return null;
        }
        
        return commentResults.first;
      });
      
      if (comment != null) {
        final upvotes = isUpvote 
            ? (comment[0] as int) + 1 
            : (comment[0] as int);
        final downvotes = !isUpvote 
            ? (comment[1] as int) + 1 
            : (comment[1] as int);
        await updateCommentVotes(commentId, upvotes, downvotes);
      }
    }
  }
  
  Future<bool> hasUserVoted(
    String userId,
    String? postId,
    String? commentId,
  ) async {
    assert(postId != null || commentId != null);
    assert(!(postId != null && commentId != null));
    
    return await _executeDB((conn) async {
      if (postId != null) {
        final results = await conn.execute(
          Sql.named('''
            SELECT COUNT(*) FROM user_votes
            WHERE user_id = @userId AND post_id = @postId
          '''),
          parameters: {
            'userId': userId,
            'postId': postId,
          },
        );
        
        return (results.first[0] as int) > 0;
      } else if (commentId != null) {
        final results = await conn.execute(
          Sql.named('''
            SELECT COUNT(*) FROM user_votes
            WHERE user_id = @userId AND comment_id = @commentId
          '''),
          parameters: {
            'userId': userId,
            'commentId': commentId,
          },
        );
        
        return (results.first[0] as int) > 0;
      }
      
      return false;
    }, defaultValue: false);
  }
  
  Future<bool?> getUserVoteType(
    String userId,
    String? postId,
    String? commentId,
  ) async {
    assert(postId != null || commentId != null);
    assert(!(postId != null && commentId != null));
    
    return await _executeDB((conn) async {
      if (postId != null) {
        final results = await conn.execute(
          Sql.named('''
            SELECT is_upvote FROM user_votes
            WHERE user_id = @userId AND post_id = @postId
          '''),
          parameters: {
            'userId': userId,
            'postId': postId,
          },
        );
        
        if (results.isEmpty) {
          return null;
        }
        
        return results.first[0] as bool;
      } else if (commentId != null) {
        final results = await conn.execute(
          Sql.named('''
            SELECT is_upvote FROM user_votes
            WHERE user_id = @userId AND comment_id = @commentId
          '''),
          parameters: {
            'userId': userId,
            'commentId': commentId,
          },
        );
        
        if (results.isEmpty) {
          return null;
        }
        
        return results.first[0] as bool;
      }
      
      return null;
    }, defaultValue: null);
  }
  
  // Search operations
  Future<List<Game>> searchGames(String query) async {
    if (_webDatabaseDisabled) {
      // Simple search in mock data
      final lowerQuery = query.toLowerCase();
      return _getMockGames().where((game) => 
          game.name.toLowerCase().contains(lowerQuery) ||
          game.description.toLowerCase().contains(lowerQuery)
      ).toList();
    }
    
    final gameIds = await _executeDB((conn) async {
      final results = await conn.execute(
        Sql.named('''
          SELECT id FROM games
          WHERE name ILIKE @query
             OR description ILIKE @query
             OR developer ILIKE @query
             OR publisher ILIKE @query
        '''),
        parameters: {
          'query': '%$query%',
        },
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
  
  Future<List<Post>> searchPosts(String query) async {
    final postIds = await _executeDB((conn) async {
      final results = await conn.execute(
        Sql.named('''
          SELECT id FROM posts
          WHERE title ILIKE @query
             OR content ILIKE @query
             OR game_name ILIKE @query
             OR author_name ILIKE @query
        '''),
        parameters: {
          'query': '%$query%',
        },
      );
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
  
  Future<List<Post>> searchPostsByTag(String tag) async {
    final postIds = await _executeDB((conn) async {
      final results = await conn.execute(
        Sql.named('''
          SELECT post_id FROM post_tags
          WHERE tag ILIKE @tag
        '''),
        parameters: {
          'tag': tag,
        },
      );
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
  
  // Seed data method to populate the database with initial data
  Future<void> _seedData() async {
    print('Seeding database with initial data...');
    
    // Create default user
    final defaultUser = User(
      id: 'user-1',
      username: 'admin',
      email: 'admin@guidegenie.com',
      bio: 'Guide Genie Admin',
      avatarUrl: 'https://ui-avatars.com/api/?name=Admin&background=random',
      favoriteGames: [],
      upvotedPosts: [],
      downvotedPosts: [],
      upvotedComments: [],
      downvotedComments: [],
      reputation: 100,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    
    await createUser(defaultUser, 'admin123'); // Simple password hash for demo
    
    // Create games from our mock data
    for (final game in _getMockGames()) {
      await createGame(game);
    }
    
    // Create sample posts
    final samplePosts = [
      Post(
        id: 'post-1',
        title: 'Ultimate Fortnite Building Guide',
        content: 'Here are the best building techniques for Fortnite...',
        gameId: 'fortnite',
        gameName: 'Fortnite',
        type: 'guide',
        authorId: 'user-1',
        authorName: 'admin',
        authorAvatarUrl: 'https://ui-avatars.com/api/?name=Admin&background=random',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        upvotes: 15,
        downvotes: 2,
        commentCount: 3,
        isFeatured: true,
        tags: ['building', 'beginner', 'tips'],
      ),
      Post(
        id: 'post-2',
        title: 'Top League of Legends Champions (Season 14)',
        content: 'The best champion picks for each role this season...',
        gameId: 'league-of-legends',
        gameName: 'League of Legends',
        type: 'tier-list',
        authorId: 'user-1',
        authorName: 'admin',
        authorAvatarUrl: 'https://ui-avatars.com/api/?name=Admin&background=random',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        upvotes: 24,
        downvotes: 3,
        commentCount: 7,
        isFeatured: true,
        tags: ['tier-list', 'meta', 'champions'],
      ),
      Post(
        id: 'post-3',
        title: 'Valorant Agent Tier List & Analysis',
        content: 'A complete breakdown of all Valorant agents by tier...',
        gameId: 'valorant',
        gameName: 'Valorant',
        type: 'tier-list',
        authorId: 'user-1',
        authorName: 'admin',
        authorAvatarUrl: 'https://ui-avatars.com/api/?name=Admin&background=random',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        upvotes: 18,
        downvotes: 1,
        commentCount: 5,
        isFeatured: true,
        tags: ['tier-list', 'agents', 'meta'],
      ),
    ];
    
    for (final post in samplePosts) {
      await createPost(post);
    }
    
    // Add some comments
    final sampleComments = [
      Comment(
        id: 'comment-1',
        postId: 'post-1',
        content: 'Great guide! This helped me improve a lot!',
        authorId: 'user-1',
        authorName: 'admin',
        authorAvatarUrl: 'https://ui-avatars.com/api/?name=Admin&background=random',
        createdAt: DateTime.now(),
        upvotes: 5,
        downvotes: 0,
      ),
      Comment(
        id: 'comment-2',
        postId: 'post-2',
        content: 'I disagree with your assessment of top lane champions.',
        authorId: 'user-1',
        authorName: 'admin',
        authorAvatarUrl: 'https://ui-avatars.com/api/?name=Admin&background=random',
        createdAt: DateTime.now(),
        upvotes: 2,
        downvotes: 3,
      ),
      Comment(
        id: 'comment-3',
        postId: 'post-3',
        content: 'Spot on with the Valorant agent analysis!',
        authorId: 'user-1',
        authorName: 'admin',
        authorAvatarUrl: 'https://ui-avatars.com/api/?name=Admin&background=random',
        createdAt: DateTime.now(),
        upvotes: 7,
        downvotes: 0,
      ),
    ];
    
    for (final comment in sampleComments) {
      await createComment(comment);
    }
    
    print('Database seeding completed successfully!');
  }
}