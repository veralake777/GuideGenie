import 'dart:async';
import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/models/post.dart';
import 'package:guide_genie/models/user.dart';
import 'package:guide_genie/models/comment.dart';

class PostgresDatabase {
  static final PostgresDatabase _instance = PostgresDatabase._internal();
  factory PostgresDatabase() => _instance;
  
  PostgresDatabase._internal();
  
  late Connection _connection;
  bool _isConnected = false;
  
  Future<void> connect() async {
    if (_isConnected) return;
    
    print('PostgresDatabase: Attempting to connect to database...');
    
    try {
      // Directly use the environment variable from Replit
      String? databaseUrl = const String.fromEnvironment('DATABASE_URL');
      
      try {
        // If not found in environment, try to load from dotenv
        if (databaseUrl == null || databaseUrl.isEmpty) {
          print('PostgresDatabase: DATABASE_URL from environment is empty, trying dotenv...');
          await dotenv.load();
          databaseUrl = dotenv.env['DATABASE_URL'];
        }
        
        // For security, mask the password in logs
        if (databaseUrl != null && databaseUrl.isNotEmpty) {
          print('PostgresDatabase: Using database URL: ${databaseUrl.replaceAll(RegExp(r'postgres://[^:]+:[^@]+@'), 'postgres://user:password@')}');
        }
      } catch (e) {
        print('PostgresDatabase: Error getting DATABASE_URL from dotenv: $e');
      }
      
      // Try connecting using the direct environment variables first (Replit provides these)
      String? pgUser = const String.fromEnvironment('PGUSER');
      String? pgPassword = const String.fromEnvironment('PGPASSWORD');
      String? pgHost = const String.fromEnvironment('PGHOST');
      String? pgDatabase = const String.fromEnvironment('PGDATABASE');
      String? pgPort = const String.fromEnvironment('PGPORT');
      
      if (pgHost != null && pgHost.isNotEmpty) {
        print('PostgresDatabase: Using direct PostgreSQL environment variables');
        print('PostgresDatabase: Host: $pgHost, DB: $pgDatabase, User: $pgUser');
        
        _connection = Connection(
          host: pgHost,
          port: int.tryParse(pgPort ?? '') ?? 5432,
          database: pgDatabase ?? 'postgres',
          username: pgUser ?? 'postgres',
          password: pgPassword ?? '',
        );
      } 
      // If direct variables not available, try using DATABASE_URL
      else if (databaseUrl != null && databaseUrl.isNotEmpty) {
        print('PostgresDatabase: Connecting using DATABASE_URL...');
        
        // Parse the database URL manually
        final uri = Uri.parse(databaseUrl);
        final userInfo = uri.userInfo.split(':');
        final username = userInfo[0];
        final password = userInfo.length > 1 ? userInfo[1] : '';
        final database = uri.path.replaceFirst('/', '');
        
        print('PostgresDatabase: Parsed DATABASE_URL - Host: ${uri.host}, Port: ${uri.port}, DB: $database, User: $username');
        
        _connection = Connection(
          host: uri.host,
          port: uri.port,
          database: database,
          username: username,
          password: password,
        );
      } 
      // Fallback to default development values as last resort
      else {
        print('PostgresDatabase: No database connection info found, using fallback parameters...');
        final host = 'localhost'; 
        final port = 5432;
        final database = 'postgres';
        final username = 'postgres';
        final password = '';
        
        print('PostgresDatabase: Using fallback connection details - Host: $host, Port: $port, DB: $database, User: $username');
        
        _connection = Connection(
          host: host,
          port: port, 
          database: database,
          username: username,
          password: password,
        );
      }
      
      print('PostgresDatabase: Opening connection...');
      await _connection.open();
      _isConnected = true;
      print('PostgresDatabase: Connection established successfully');
      
      print('PostgresDatabase: Creating tables if they don\'t exist...');
      await _createTables();
      print('PostgresDatabase: Tables created/verified');
      
      // Check if seed data needs to be inserted
      print('PostgresDatabase: Checking if seed data is needed...');
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
      rethrow;
    }
  }
  
  Future<void> close() async {
    if (_isConnected) {
      await _connection.close();
      _isConnected = false;
    }
  }
  
  Future<void> _createTables() async {
    await _connection.execute('''
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
    
    await _connection.execute('''
      CREATE TABLE IF NOT EXISTS favorite_games (
        user_id TEXT,
        game_id TEXT,
        PRIMARY KEY (user_id, game_id),
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    await _connection.execute('''
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
    
    await _connection.execute('''
      CREATE TABLE IF NOT EXISTS game_platforms (
        game_id TEXT,
        platform TEXT,
        PRIMARY KEY (game_id, platform),
        FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE
      )
    ''');
    
    await _connection.execute('''
      CREATE TABLE IF NOT EXISTS game_genres (
        game_id TEXT,
        genre TEXT,
        PRIMARY KEY (game_id, genre),
        FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE
      )
    ''');
    
    await _connection.execute('''
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
    
    await _connection.execute('''
      CREATE TABLE IF NOT EXISTS post_tags (
        post_id TEXT,
        tag TEXT,
        PRIMARY KEY (post_id, tag),
        FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE
      )
    ''');
    
    await _connection.execute('''
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
    
    await _connection.execute('''
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
  }
  
  // User operations
  Future<void> createUser(User user, String passwordHash) async {
    await connect();
    
    await _connection.execute('''
      INSERT INTO users (id, username, email, password_hash, bio, avatar_url, reputation)
      VALUES (@id, @username, @email, @passwordHash, @bio, @avatarUrl, @reputation)
    ''', substitutionValues: {
      'id': user.id,
      'username': user.username,
      'email': user.email,
      'passwordHash': passwordHash,
      'bio': user.bio,
      'avatarUrl': user.avatarUrl,
      'reputation': user.reputation,
    });
    
    // Insert favorite games
    for (final gameId in user.favoriteGames) {
      await _connection.execute('''
        INSERT INTO favorite_games (user_id, game_id)
        VALUES (@userId, @gameId)
      ''', substitutionValues: {
        'userId': user.id,
        'gameId': gameId,
      });
    }
  }
  
  Future<User?> getUserById(String userId) async {
    await connect();
    
    final results = await _connection.query('''
      SELECT * FROM users WHERE id = @userId
    ''', substitutionValues: {
      'userId': userId,
    });
    
    if (results.isEmpty) {
      return null;
    }
    
    final userData = results.first;
    
    // Get favorite games
    final favoriteResults = await _connection.query('''
      SELECT game_id FROM favorite_games WHERE user_id = @userId
    ''', substitutionValues: {
      'userId': userId,
    });
    
    final favoriteGames = favoriteResults.map((row) => row[0] as String).toList();
    
    // Get upvoted posts
    final upvotedPostsResults = await _connection.query('''
      SELECT post_id FROM user_votes
      WHERE user_id = @userId AND post_id IS NOT NULL AND is_upvote = TRUE
    ''', substitutionValues: {
      'userId': userId,
    });
    
    final upvotedPosts = upvotedPostsResults.map((row) => row[0] as String).toList();
    
    // Get downvoted posts
    final downvotedPostsResults = await _connection.query('''
      SELECT post_id FROM user_votes
      WHERE user_id = @userId AND post_id IS NOT NULL AND is_upvote = FALSE
    ''', substitutionValues: {
      'userId': userId,
    });
    
    final downvotedPosts = downvotedPostsResults.map((row) => row[0] as String).toList();
    
    // Get upvoted comments
    final upvotedCommentsResults = await _connection.query('''
      SELECT comment_id FROM user_votes
      WHERE user_id = @userId AND comment_id IS NOT NULL AND is_upvote = TRUE
    ''', substitutionValues: {
      'userId': userId,
    });
    
    final upvotedComments = upvotedCommentsResults.map((row) => row[0] as String).toList();
    
    // Get downvoted comments
    final downvotedCommentsResults = await _connection.query('''
      SELECT comment_id FROM user_votes
      WHERE user_id = @userId AND comment_id IS NOT NULL AND is_upvote = FALSE
    ''', substitutionValues: {
      'userId': userId,
    });
    
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
  }
  
  Future<User?> getUserByEmail(String email) async {
    await connect();
    
    final results = await _connection.query('''
      SELECT * FROM users WHERE email = @email
    ''', substitutionValues: {
      'email': email,
    });
    
    if (results.isEmpty) {
      return null;
    }
    
    final userId = results.first[0] as String;
    return getUserById(userId);
  }
  
  Future<User?> getUserByUsername(String username) async {
    await connect();
    
    final results = await _connection.query('''
      SELECT * FROM users WHERE username = @username
    ''', substitutionValues: {
      'username': username,
    });
    
    if (results.isEmpty) {
      return null;
    }
    
    final userId = results.first[0] as String;
    return getUserById(userId);
  }
  
  Future<List<User>> getAllUsers() async {
    await connect();
    
    final results = await _connection.query('SELECT id FROM users');
    
    final users = <User>[];
    for (final row in results) {
      final userId = row[0] as String;
      final user = await getUserById(userId);
      if (user != null) {
        users.add(user);
      }
    }
    
    return users;
  }
  
  Future<String?> getUserPasswordHash(String email) async {
    await connect();
    
    final results = await _connection.query('''
      SELECT password_hash FROM users WHERE email = @email
    ''', substitutionValues: {
      'email': email,
    });
    
    if (results.isEmpty) {
      return null;
    }
    
    return results.first[0] as String;
  }
  
  Future<void> updateUser(User user) async {
    await connect();
    
    await _connection.execute('''
      UPDATE users
      SET username = @username,
          email = @email,
          bio = @bio,
          avatar_url = @avatarUrl,
          reputation = @reputation,
          last_login = @lastLogin
      WHERE id = @id
    ''', substitutionValues: {
      'id': user.id,
      'username': user.username,
      'email': user.email,
      'bio': user.bio,
      'avatarUrl': user.avatarUrl,
      'reputation': user.reputation,
      'lastLogin': user.lastLogin.toIso8601String(),
    });
    
    // Update favorite games
    await _connection.execute('''
      DELETE FROM favorite_games WHERE user_id = @userId
    ''', substitutionValues: {
      'userId': user.id,
    });
    
    for (final gameId in user.favoriteGames) {
      await _connection.execute('''
        INSERT INTO favorite_games (user_id, game_id)
        VALUES (@userId, @gameId)
      ''', substitutionValues: {
        'userId': user.id,
        'gameId': gameId,
      });
    }
  }
  
  Future<void> updateUserLastLogin(String userId) async {
    await connect();
    
    await _connection.execute('''
      UPDATE users
      SET last_login = CURRENT_TIMESTAMP
      WHERE id = @id
    ''', substitutionValues: {
      'id': userId,
    });
  }
  
  Future<void> updateUserPassword(String userId, String passwordHash) async {
    await connect();
    
    await _connection.execute('''
      UPDATE users
      SET password_hash = @passwordHash
      WHERE id = @id
    ''', substitutionValues: {
      'id': userId,
      'passwordHash': passwordHash,
    });
  }
  
  // Game operations
  Future<void> createGame(Game game) async {
    await connect();
    
    await _connection.execute('''
      INSERT INTO games (
        id, name, description, cover_image_url, developer, publisher,
        release_date, rating, post_count, is_featured
      )
      VALUES (
        @id, @name, @description, @coverImageUrl, @developer, @publisher,
        @releaseDate, @rating, @postCount, @isFeatured
      )
    ''', substitutionValues: {
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
    });
    
    // Insert platforms
    for (final platform in game.platforms) {
      await _connection.execute('''
        INSERT INTO game_platforms (game_id, platform)
        VALUES (@gameId, @platform)
      ''', substitutionValues: {
        'gameId': game.id,
        'platform': platform,
      });
    }
    
    // Insert genres
    for (final genre in game.genres) {
      await _connection.execute('''
        INSERT INTO game_genres (game_id, genre)
        VALUES (@gameId, @genre)
      ''', substitutionValues: {
        'gameId': game.id,
        'genre': genre,
      });
    }
  }
  
  Future<Game?> getGameById(String gameId) async {
    await connect();
    
    final results = await _connection.query('''
      SELECT * FROM games WHERE id = @gameId
    ''', substitutionValues: {
      'gameId': gameId,
    });
    
    if (results.isEmpty) {
      return null;
    }
    
    final gameData = results.first;
    
    // Get platforms
    final platformResults = await _connection.query('''
      SELECT platform FROM game_platforms WHERE game_id = @gameId
    ''', substitutionValues: {
      'gameId': gameId,
    });
    
    final platforms = platformResults.map((row) => row[0] as String).toList();
    
    // Get genres
    final genreResults = await _connection.query('''
      SELECT genre FROM game_genres WHERE game_id = @gameId
    ''', substitutionValues: {
      'gameId': gameId,
    });
    
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
  }
  
  Future<List<Game>> getAllGames() async {
    await connect();
    
    final results = await _connection.query('SELECT id FROM games');
    
    final games = <Game>[];
    for (final row in results) {
      final gameId = row[0] as String;
      final game = await getGameById(gameId);
      if (game != null) {
        games.add(game);
      }
    }
    
    return games;
  }
  
  Future<List<Game>> getFeaturedGames() async {
    await connect();
    
    final results = await _connection.query('''
      SELECT id FROM games WHERE is_featured = TRUE
    ''');
    
    final games = <Game>[];
    for (final row in results) {
      final gameId = row[0] as String;
      final game = await getGameById(gameId);
      if (game != null) {
        games.add(game);
      }
    }
    
    return games;
  }
  
  Future<void> updateGamePostCount(String gameId, int count) async {
    await connect();
    
    await _connection.execute('''
      UPDATE games
      SET post_count = @count
      WHERE id = @id
    ''', substitutionValues: {
      'id': gameId,
      'count': count,
    });
  }
  
  // Post operations
  Future<void> createPost(Post post) async {
    await connect();
    
    await _connection.execute('''
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
    ''', substitutionValues: {
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
    });
    
    // Insert tags
    for (final tag in post.tags) {
      await _connection.execute('''
        INSERT INTO post_tags (post_id, tag)
        VALUES (@postId, @tag)
      ''', substitutionValues: {
        'postId': post.id,
        'tag': tag,
      });
    }
    
    // Update game post count
    final game = await getGameById(post.gameId);
    if (game != null) {
      await updateGamePostCount(post.gameId, game.postCount + 1);
    }
  }
  
  Future<Post?> getPostById(String postId) async {
    await connect();
    
    final results = await _connection.query('''
      SELECT * FROM posts WHERE id = @postId
    ''', substitutionValues: {
      'postId': postId,
    });
    
    if (results.isEmpty) {
      return null;
    }
    
    final postData = results.first;
    
    // Get tags
    final tagResults = await _connection.query('''
      SELECT tag FROM post_tags WHERE post_id = @postId
    ''', substitutionValues: {
      'postId': postId,
    });
    
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
  }
  
  Future<List<Post>> getAllPosts() async {
    await connect();
    
    final results = await _connection.query('SELECT id FROM posts');
    
    final posts = <Post>[];
    for (final row in results) {
      final postId = row[0] as String;
      final post = await getPostById(postId);
      if (post != null) {
        posts.add(post);
      }
    }
    
    return posts;
  }
  
  Future<List<Post>> getFeaturedPosts() async {
    await connect();
    
    final results = await _connection.query('''
      SELECT id FROM posts WHERE is_featured = TRUE
    ''');
    
    final posts = <Post>[];
    for (final row in results) {
      final postId = row[0] as String;
      final post = await getPostById(postId);
      if (post != null) {
        posts.add(post);
      }
    }
    
    return posts;
  }
  
  Future<List<Post>> getLatestPosts(int limit) async {
    await connect();
    
    final results = await _connection.query('''
      SELECT id FROM posts ORDER BY created_at DESC LIMIT @limit
    ''', substitutionValues: {
      'limit': limit,
    });
    
    final posts = <Post>[];
    for (final row in results) {
      final postId = row[0] as String;
      final post = await getPostById(postId);
      if (post != null) {
        posts.add(post);
      }
    }
    
    return posts;
  }
  
  Future<List<Post>> getPostsByGame(String gameId) async {
    await connect();
    
    final results = await _connection.query('''
      SELECT id FROM posts WHERE game_id = @gameId
    ''', substitutionValues: {
      'gameId': gameId,
    });
    
    final posts = <Post>[];
    for (final row in results) {
      final postId = row[0] as String;
      final post = await getPostById(postId);
      if (post != null) {
        posts.add(post);
      }
    }
    
    return posts;
  }
  
  Future<List<Post>> getPostsByUser(String userId) async {
    await connect();
    
    final results = await _connection.query('''
      SELECT id FROM posts WHERE author_id = @userId
    ''', substitutionValues: {
      'userId': userId,
    });
    
    final posts = <Post>[];
    for (final row in results) {
      final postId = row[0] as String;
      final post = await getPostById(postId);
      if (post != null) {
        posts.add(post);
      }
    }
    
    return posts;
  }
  
  Future<void> updatePostVotes(String postId, int upvotes, int downvotes) async {
    await connect();
    
    await _connection.execute('''
      UPDATE posts
      SET upvotes = @upvotes, downvotes = @downvotes
      WHERE id = @id
    ''', substitutionValues: {
      'id': postId,
      'upvotes': upvotes,
      'downvotes': downvotes,
    });
  }
  
  Future<void> updatePostCommentCount(String postId, int count) async {
    await connect();
    
    await _connection.execute('''
      UPDATE posts
      SET comment_count = @count
      WHERE id = @id
    ''', substitutionValues: {
      'id': postId,
      'count': count,
    });
  }
  
  // Comment operations
  Future<void> createComment(Comment comment) async {
    await connect();
    
    await _connection.execute('''
      INSERT INTO comments (
        id, post_id, content, author_id, author_name,
        author_avatar_url, created_at, upvotes, downvotes
      )
      VALUES (
        @id, @postId, @content, @authorId, @authorName,
        @authorAvatarUrl, @createdAt, @upvotes, @downvotes
      )
    ''', substitutionValues: {
      'id': comment.id,
      'postId': comment.postId,
      'content': comment.content,
      'authorId': comment.authorId,
      'authorName': comment.authorName,
      'authorAvatarUrl': comment.authorAvatarUrl,
      'createdAt': comment.createdAt.toIso8601String(),
      'upvotes': comment.upvotes,
      'downvotes': comment.downvotes,
    });
    
    // Update post comment count
    final post = await getPostById(comment.postId);
    if (post != null) {
      await updatePostCommentCount(comment.postId, post.commentCount + 1);
    }
  }
  
  Future<List<Comment>> getCommentsByPost(String postId) async {
    await connect();
    
    final results = await _connection.query('''
      SELECT * FROM comments
      WHERE post_id = @postId
      ORDER BY created_at DESC
    ''', substitutionValues: {
      'postId': postId,
    });
    
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
  }
  
  Future<void> updateCommentVotes(String commentId, int upvotes, int downvotes) async {
    await connect();
    
    await _connection.execute('''
      UPDATE comments
      SET upvotes = @upvotes, downvotes = @downvotes
      WHERE id = @id
    ''', substitutionValues: {
      'id': commentId,
      'upvotes': upvotes,
      'downvotes': downvotes,
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
    
    await connect();
    
    // Delete existing vote if any
    if (postId != null) {
      await _connection.execute('''
        DELETE FROM user_votes
        WHERE user_id = @userId AND post_id = @postId
      ''', substitutionValues: {
        'userId': userId,
        'postId': postId,
      });
    } else if (commentId != null) {
      await _connection.execute('''
        DELETE FROM user_votes
        WHERE user_id = @userId AND comment_id = @commentId
      ''', substitutionValues: {
        'userId': userId,
        'commentId': commentId,
      });
    }
    
    // Insert new vote
    await _connection.execute('''
      INSERT INTO user_votes (user_id, post_id, comment_id, is_upvote)
      VALUES (@userId, @postId, @commentId, @isUpvote)
    ''', substitutionValues: {
      'userId': userId,
      'postId': postId,
      'commentId': commentId,
      'isUpvote': isUpvote,
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
      final commentResults = await _connection.query('''
        SELECT upvotes, downvotes FROM comments WHERE id = @commentId
      ''', substitutionValues: {
        'commentId': commentId,
      });
      
      if (commentResults.isNotEmpty) {
        final upvotes = isUpvote 
            ? (commentResults.first[0] as int) + 1 
            : (commentResults.first[0] as int);
        final downvotes = !isUpvote 
            ? (commentResults.first[1] as int) + 1 
            : (commentResults.first[1] as int);
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
    
    await connect();
    
    if (postId != null) {
      final results = await _connection.query('''
        SELECT COUNT(*) FROM user_votes
        WHERE user_id = @userId AND post_id = @postId
      ''', substitutionValues: {
        'userId': userId,
        'postId': postId,
      });
      
      return (results.first[0] as int) > 0;
    } else if (commentId != null) {
      final results = await _connection.query('''
        SELECT COUNT(*) FROM user_votes
        WHERE user_id = @userId AND comment_id = @commentId
      ''', substitutionValues: {
        'userId': userId,
        'commentId': commentId,
      });
      
      return (results.first[0] as int) > 0;
    }
    
    return false;
  }
  
  Future<bool?> getUserVoteType(
    String userId,
    String? postId,
    String? commentId,
  ) async {
    assert(postId != null || commentId != null);
    assert(!(postId != null && commentId != null));
    
    await connect();
    
    if (postId != null) {
      final results = await _connection.query('''
        SELECT is_upvote FROM user_votes
        WHERE user_id = @userId AND post_id = @postId
      ''', substitutionValues: {
        'userId': userId,
        'postId': postId,
      });
      
      if (results.isEmpty) {
        return null;
      }
      
      return results.first[0] as bool;
    } else if (commentId != null) {
      final results = await _connection.query('''
        SELECT is_upvote FROM user_votes
        WHERE user_id = @userId AND comment_id = @commentId
      ''', substitutionValues: {
        'userId': userId,
        'commentId': commentId,
      });
      
      if (results.isEmpty) {
        return null;
      }
      
      return results.first[0] as bool;
    }
    
    return null;
  }
  
  // Search operations
  Future<List<Game>> searchGames(String query) async {
    await connect();
    
    final results = await _connection.query('''
      SELECT id FROM games
      WHERE name ILIKE @query
         OR description ILIKE @query
         OR developer ILIKE @query
         OR publisher ILIKE @query
    ''', substitutionValues: {
      'query': '%$query%',
    });
    
    final games = <Game>[];
    for (final row in results) {
      final gameId = row[0] as String;
      final game = await getGameById(gameId);
      if (game != null) {
        games.add(game);
      }
    }
    
    return games;
  }
  
  Future<List<Post>> searchPosts(String query) async {
    await connect();
    
    final results = await _connection.query('''
      SELECT id FROM posts
      WHERE title ILIKE @query
         OR content ILIKE @query
         OR game_name ILIKE @query
         OR author_name ILIKE @query
    ''', substitutionValues: {
      'query': '%$query%',
    });
    
    final posts = <Post>[];
    for (final row in results) {
      final postId = row[0] as String;
      final post = await getPostById(postId);
      if (post != null) {
        posts.add(post);
      }
    }
    
    return posts;
  }
  
  Future<List<Post>> searchPostsByTag(String tag) async {
    await connect();
    
    final results = await _connection.query('''
      SELECT post_id FROM post_tags
      WHERE tag ILIKE @tag
    ''', substitutionValues: {
      'tag': tag,
    });
    
    final posts = <Post>[];
    for (final row in results) {
      final postId = row[0] as String;
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
    
    await createUser(defaultUser, 'hashed_password'); // In a real app, this would be properly hashed
    
    // Create games
    final fortnite = Game(
      id: 'game-1',
      title: 'Fortnite',
      name: 'Fortnite',
      genre: 'Battle Royale',
      imageUrl: 'https://cdn2.unrealengine.com/social-image-chapter4-s3-3840x2160-d35912cc25ad.jpg',
      description: 'A battle royale game where 100 players fight to be the last person standing.',
      coverImageUrl: 'https://cdn2.unrealengine.com/social-image-chapter4-s3-3840x2160-d35912cc25ad.jpg',
      developer: 'Epic Games',
      publisher: 'Epic Games',
      releaseDate: '2017-07-25',
      platforms: ['PC', 'PlayStation', 'Xbox', 'Switch', 'Mobile'],
      genres: ['Battle Royale', 'Shooter', 'Survival'],
      rating: 4.5,
      postCount: 0,
      isFeatured: true,
    );
    
    final leagueOfLegends = Game(
      id: 'game-2',
      title: 'League of Legends',
      name: 'League of Legends',
      genre: 'MOBA',
      imageUrl: 'https://www.leagueoflegends.com/static/open-graph-2e582ae9fae8b0b396ca46ff21fd47a8.jpg',
      description: 'A team-based strategy game where two teams of five champions compete to destroy the enemy base.',
      coverImageUrl: 'https://www.leagueoflegends.com/static/open-graph-2e582ae9fae8b0b396ca46ff21fd47a8.jpg',
      developer: 'Riot Games',
      publisher: 'Riot Games',
      releaseDate: '2009-10-27',
      platforms: ['PC', 'Mac'],
      genres: ['MOBA', 'Strategy', 'Multiplayer'],
      rating: 4.2,
      postCount: 0,
      isFeatured: true,
    );
    
    final valorant = Game(
      id: 'game-3',
      title: 'Valorant',
      name: 'Valorant',
      genre: 'Tactical FPS',
      imageUrl: 'https://images.contentstack.io/v3/assets/bltb6530b271fddd0b1/blt3f072336e3f3ade4/63096d7be4a8c30e088e7720/Valorant_2022_E5A2_PlayVALORANT_ContentStackThumbnail_1200x625_MB01.png',
      description: 'A 5v5 character-based tactical shooter where precise gunplay meets unique agent abilities.',
      coverImageUrl: 'https://images.contentstack.io/v3/assets/bltb6530b271fddd0b1/blt3f072336e3f3ade4/63096d7be4a8c30e088e7720/Valorant_2022_E5A2_PlayVALORANT_ContentStackThumbnail_1200x625_MB01.png',
      developer: 'Riot Games',
      publisher: 'Riot Games',
      releaseDate: '2020-06-02',
      platforms: ['PC'],
      genres: ['Tactical Shooter', 'FPS', 'Multiplayer'],
      rating: 4.4,
      postCount: 0,
      isFeatured: false,
    );
    
    final streetFighter = Game(
      id: 'game-4',
      title: 'Street Fighter 6',
      name: 'Street Fighter 6',
      genre: 'Fighting',
      imageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/1364780/capsule_616x353.jpg',
      description: 'The latest entry in the legendary fighting game franchise with new mechanics and characters.',
      coverImageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/1364780/capsule_616x353.jpg',
      developer: 'Capcom',
      publisher: 'Capcom',
      releaseDate: '2023-06-02',
      platforms: ['PC', 'PlayStation', 'Xbox'],
      genres: ['Fighting', 'Arcade', 'Competitive'],
      rating: 4.7,
      postCount: 0,
      isFeatured: true,
    );
    
    final callOfDuty = Game(
      id: 'game-5',
      title: 'Call of Duty: Modern Warfare III',
      name: 'Call of Duty: Modern Warfare III',
      genre: 'FPS',
      imageUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/mw3/meta-images/season-2/WZ_MWIII_S02_KEY_ART_16x9.jpg',
      description: 'The latest installment in the Call of Duty franchise featuring both multiplayer and campaign modes.',
      coverImageUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/mw3/meta-images/season-2/WZ_MWIII_S02_KEY_ART_16x9.jpg',
      developer: 'Infinity Ward',
      publisher: 'Activision',
      releaseDate: '2023-11-10',
      platforms: ['PC', 'PlayStation', 'Xbox'],
      genres: ['FPS', 'Action', 'Multiplayer'],
      rating: 4.1,
      postCount: 0,
      isFeatured: false,
    );
    
    final warzone = Game(
      id: 'game-6',
      title: 'Call of Duty: Warzone',
      name: 'Call of Duty: Warzone',
      genre: 'Battle Royale',
      imageUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/blog/hero/mw-wz/WZ-Season-Three-Announce-TOUT.jpg',
      description: 'A free-to-play battle royale game from the Call of Duty franchise.',
      coverImageUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/blog/hero/mw-wz/WZ-Season-Three-Announce-TOUT.jpg',
      developer: 'Infinity Ward',
      publisher: 'Activision',
      releaseDate: '2020-03-10',
      platforms: ['PC', 'PlayStation', 'Xbox'],
      genres: ['Battle Royale', 'FPS', 'Action'],
      rating: 4.3,
      postCount: 0,
      isFeatured: false,
    );
    
    final marvelRivals = Game(
      id: 'game-7',
      title: 'Marvel Rivals',
      name: 'Marvel Rivals',
      genre: 'Hero Shooter',
      imageUrl: 'https://cdn1.epicgames.com/offer/9ce578fa87934fa2b2cff24c6c388879/EGS_MarvelRivals_NetEaseGames_S2_1200x1600-1af611a128ddb0c059eb09e94e8dddc0',
      description: 'A team-based hero shooter set in the Marvel universe.',
      coverImageUrl: 'https://cdn1.epicgames.com/offer/9ce578fa87934fa2b2cff24c6c388879/EGS_MarvelRivals_NetEaseGames_S2_1200x1600-1af611a128ddb0c059eb09e94e8dddc0',
      developer: 'NetEase Games',
      publisher: 'Marvel Entertainment',
      releaseDate: '2024-07-15',
      platforms: ['PC', 'PlayStation', 'Xbox'],
      genres: ['Hero Shooter', 'Action', 'Multiplayer'],
      rating: 4.6,
      postCount: 0,
      isFeatured: true,
    );
    
    await createGame(fortnite);
    await createGame(leagueOfLegends);
    await createGame(valorant);
    await createGame(streetFighter);
    await createGame(callOfDuty);
    await createGame(warzone);
    await createGame(marvelRivals);
    
    // Create posts
    final fortniteTierListPost = Post(
      id: 'post-1',
      title: 'Fortnite Season 5 Weapons Tier List',
      content: 'Here\'s my comprehensive tier list for all weapons in Fortnite Season 5:\n\n'
          '## S Tier\n'
          '- Legendary Assault Rifle\n'
          '- Legendary Pump Shotgun\n'
          '- Legendary Sniper Rifle\n\n'
          '## A Tier\n'
          '- Epic Assault Rifle\n'
          '- Epic Tactical Shotgun\n'
          '- Legendary Rocket Launcher\n\n'
          '## B Tier\n'
          '- Rare Assault Rifle\n'
          '- Epic SMG\n'
          '- Rare Tactical Shotgun\n\n'
          '## C Tier\n'
          '- Common Assault Rifle\n'
          '- Common Pistol\n'
          '- Common SMG\n\n'
          'Let me know your thoughts in the comments!',
      gameId: 'game-1',
      gameName: 'Fortnite',
      type: 'tier_list',
      tags: ['weapons', 'season 5', 'meta'],
      authorId: 'user-1',
      authorName: 'admin',
      authorAvatarUrl: 'https://ui-avatars.com/api/?name=Admin&background=random',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      upvotes: 24,
      downvotes: 3,
      commentCount: 0,
      isFeatured: true,
    );
    
    final lolGuidePost = Post(
      id: 'post-2',
      title: 'ADC Role Guide: Positioning & Farming',
      content: '# ADC Role Guide\n\n'
          '## Introduction\n'
          'The ADC (Attack Damage Carry) role is critical in League of Legends. Your job is to deal consistent damage in team fights and take down objectives.\n\n'
          '## Early Game\n'
          '- Focus on last-hitting minions for gold\n'
          '- Stay behind your support and avoid trading alone\n'
          '- Ward the river bush to avoid ganks\n\n'
          '## Mid Game\n'
          '- Rotate to mid lane for objectives\n'
          '- Group with your team for dragon fights\n'
          '- Continue farming side lanes when safe\n\n'
          '## Late Game\n'
          '- Position behind your frontline in team fights\n'
          '- Focus the closest enemy champion\n'
          '- Prioritize staying alive over getting kills\n\n'
          '## Recommended Champions\n'
          '- Caitlyn: Safe pick with long range\n'
          '- Jinx: Great scaling and team fight presence\n'
          '- Ezreal: Mobile and safe with poke damage\n'
          '- Jhin: High burst damage and utility\n\n'
          'Feel free to ask questions in the comments!',
      gameId: 'game-2',
      gameName: 'League of Legends',
      type: 'guide',
      tags: ['ADC', 'beginner', 'farming', 'positioning'],
      authorId: 'user-1',
      authorName: 'admin',
      authorAvatarUrl: 'https://ui-avatars.com/api/?name=Admin&background=random',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      upvotes: 37,
      downvotes: 5,
      commentCount: 0,
      isFeatured: true,
    );
    
    final valorantAgentPost = Post(
      id: 'post-3',
      title: 'Valorant Agent Tier List - Post Patch 7.04',
      content: '# Valorant Agent Tier List (Patch 7.04)\n\n'
          '## S Tier\n'
          '- Jett: Still the queen of mobility and entry\n'
          '- Chamber: Top pick for holding angles and OPing\n'
          '- Sova: Information gathering is unmatched\n\n'
          '## A Tier\n'
          '- Sage: Healing and wall utility remain strong\n'
          '- Brimstone: Smokes and molly lineups are valuable\n'
          '- Killjoy: Great for site control and retakes\n\n'
          '## B Tier\n'
          '- Phoenix: Decent flashes but outclassed by others\n'
          '- Cypher: Good info but requires more setup\n'
          '- Viper: Map-dependent but strong when used well\n\n'
          '## C Tier\n'
          '- Yoru: Fun but inconsistent impact\n'
          '- Astra: Too complex for the value provided\n\n'
          'This list is based on both pro play and high-rank competitive matches. Let me know if you disagree!',
      gameId: 'game-3',
      gameName: 'Valorant',
      type: 'tier_list',
      tags: ['agents', 'meta', 'patch 7.04'],
      authorId: 'user-1',
      authorName: 'admin',
      authorAvatarUrl: 'https://ui-avatars.com/api/?name=Admin&background=random',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      upvotes: 15,
      downvotes: 2,
      commentCount: 0,
      isFeatured: false,
    );
    
    final streetFighterComboPost = Post(
      id: 'post-4',
      title: 'Ryu Essential Combos - Street Fighter 6',
      content: '# Ryu Essential Combos Guide\n\n'
          '## Basic Combos\n'
          '- `cr.MK > Hadoken`: Basic poke into special\n'
          '- `cr.LK > cr.LP > dp+MP`: Light confirm into medium DP\n'
          '- `MP > DP+HP`: Hit confirm into heavy DP\n\n'
          '## Drive Impact Combos\n'
          '- `Drive Impact > HP > Tatsu+MK`: Basic drive impact follow-up\n'
          '- `Drive Impact (corner) > HP > HK > DP+HP`: Corner drive impact max damage\n\n'
          '## Drive Rush Combos\n'
          '- `Drive Rush > MP > HP > DP+HP`: Drive rush pressure\n'
          '- `Drive Rush > throw`: Drive rush throw mix-up\n\n'
          '## Super Combos\n'
          '- `cr.MK > Hadoken > Level 3 Super`: Basic super confirm\n'
          '- `Drive Impact > HP > Level 2 Super`: High damage super combo\n\n'
          '## Tips\n'
          '- Practice hit-confirming cr.MK into Hadoken\n'
          '- Use drive rush to extend combos and create pressure\n'
          '- Level 3 super is best saved for round-ending situations\n\n'
          'Practice these in training mode until they become muscle memory!',
      gameId: 'game-4',
      gameName: 'Street Fighter 6',
      type: 'guide',
      tags: ['Ryu', 'combos', 'beginner'],
      authorId: 'user-1',
      authorName: 'admin',
      authorAvatarUrl: 'https://ui-avatars.com/api/?name=Admin&background=random',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      upvotes: 42,
      downvotes: 1,
      commentCount: 0,
      isFeatured: true,
    );
    
    final codWarLoadoutPost = Post(
      id: 'post-5',
      title: 'Best MW3 Meta Loadouts - Season 2',
      content: '# Best MW3 Loadouts (Season 2)\n\n'
          '## Assault Rifle: MCW\n'
          '- Muzzle: Casus Brake\n'
          '- Barrel: MCW Long Barrel\n'
          '- Optic: Corio Eagleseye 2.5x\n'
          '- Underbarrel: DR-6 Handstop\n'
          '- Magazine: 40 Round Mag\n\n'
          '## SMG: WSP Swarm\n'
          '- Muzzle: Monolithic Suppressor\n'
          '- Barrel: WSP Carbine Barrel\n'
          '- Stock: WSP Factory Stock\n'
          '- Underbarrel: XTEN Phantom Grip\n'
          '- Rear Grip: WSP Agile Grip\n\n'
          '## Sniper: MORS\n'
          '- Muzzle: Sonic Suppressor\n'
          '- Barrel: MORS-18 Heavy Barrel\n'
          '- Optic: SP-X 80 6.6x\n'
          '- Stock: MK3 Rifle Stock\n'
          '- Bolt: Quick Bolt\n\n'
          '## Perks\n'
          '- Perk 1: Double Time\n'
          '- Perk 2: Fast Hands\n'
          '- Perk 3: Tracker\n\n'
          '## Equipment\n'
          '- Tactical: Stun Grenade\n'
          '- Lethal: Semtex\n'
          '- Field Upgrade: Dead Silence\n\n'
          'These loadouts are optimized for both multiplayer and Warzone. Let me know your favorite combos!',
      gameId: 'game-5',
      gameName: 'Call of Duty: Modern Warfare III',
      type: 'loadout',
      tags: ['loadouts', 'season 2', 'meta'],
      authorId: 'user-1',
      authorName: 'admin',
      authorAvatarUrl: 'https://ui-avatars.com/api/?name=Admin&background=random',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 6)),
      upvotes: 28,
      downvotes: 4,
      commentCount: 0,
      isFeatured: false,
    );
    
    final warzoneStrategyPost = Post(
      id: 'post-6',
      title: 'Warzone Rebirth Island - Pro Rotation Strategies',
      content: '# Warzone Rebirth Island Rotation Guide\n\n'
          '## Best Drop Locations\n'
          '- **Prison**: High risk, high reward. Lots of loot and contracts.\n'
          '- **Control Center**: Central location with good positioning.\n'
          '- **Harbor**: Quieter drop with decent loot and escape options.\n\n'
          '## Early Game Strategy\n'
          '1. Secure a loadout drop ASAP\n'
          '2. Complete contracts for cash and intel\n'
          '3. Position for the first circle\n\n'
          '## Mid Game Rotations\n'
          '- **From Prison**: Rotate through Chemical Engineering or Headquarters\n'
          '- **From Control**: Move to Security Area or Bioweapons\n'
          '- **From Harbor**: Push through Decon Zone or Factory\n\n'
          '## Late Game\n'
          '- Prioritize high ground whenever possible\n'
          '- Use gas masks to make plays through the gas\n'
          '- Hold power positions in the final circles\n\n'
          '## Advanced Tips\n'
          '- Use balloons for quick repositioning\n'
          '- Save a precision airstrike for the final circle\n'
          '- Always have a self-revive in late game\n\n'
          'These strategies are based on analysis of top Warzone players and tournament winners. Adapt them to your playstyle for the best results!',
      gameId: 'game-6',
      gameName: 'Call of Duty: Warzone',
      type: 'strategy',
      tags: ['Rebirth Island', 'rotations', 'advanced'],
      authorId: 'user-1',
      authorName: 'admin',
      authorAvatarUrl: 'https://ui-avatars.com/api/?name=Admin&background=random',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      upvotes: 19,
      downvotes: 2,
      commentCount: 0,
      isFeatured: false,
    );
    
    final marvelRivalsPost = Post(
      id: 'post-7',
      title: 'Marvel Rivals Beta - Character Tier List',
      content: '# Marvel Rivals Beta - Character Tier List\n\n'
          '## S Tier\n'
          '- **Iron Man**: Incredible mobility and damage output\n'
          '- **Doctor Strange**: Unmatched utility and crowd control\n'
          '- **Black Panther**: Perfect balance of damage and survivability\n\n'
          '## A Tier\n'
          '- **Spider-Man**: Great mobility but limited team utility\n'
          '- **Hulk**: Massive damage but predictable\n'
          '- **Magneto**: Strong control capabilities\n'
          '- **Star-Lord**: Good damage but requires team support\n\n'
          '## B Tier\n'
          '- **Rocket Raccoon**: Situational but can be devastating\n'
          '- **Storm**: Good area control but vulnerable\n'
          '- **Loki**: Tricky to master but rewarding\n\n'
          '## C Tier\n'
          '- **Mantis**: Limited damage output\n'
          '- **Groot**: Too dependent on team coordination\n\n'
          '## Best Team Compositions\n'
          '1. Iron Man, Doctor Strange, Black Panther\n'
          '2. Spider-Man, Hulk, Magneto\n'
          '3. Star-Lord, Black Panther, Storm\n\n'
          'This tier list is based on the closed beta gameplay. The meta will likely shift with balance patches and as players discover new strategies.',
      gameId: 'game-7',
      gameName: 'Marvel Rivals',
      type: 'tier_list',
      tags: ['characters', 'beta', 'team comps'],
      authorId: 'user-1',
      authorName: 'admin',
      authorAvatarUrl: 'https://ui-avatars.com/api/?name=Admin&background=random',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      upvotes: 31,
      downvotes: 3,
      commentCount: 0,
      isFeatured: true,
    );
    
    await createPost(fortniteTierListPost);
    await createPost(lolGuidePost);
    await createPost(valorantAgentPost);
    await createPost(streetFighterComboPost);
    await createPost(codWarLoadoutPost);
    await createPost(warzoneStrategyPost);
    await createPost(marvelRivalsPost);
    
    // Update game post counts
    await updateGamePostCount('game-1', 1); // Fortnite
    await updateGamePostCount('game-2', 1); // League of Legends
    await updateGamePostCount('game-3', 1); // Valorant
    await updateGamePostCount('game-4', 1); // Street Fighter 6
    await updateGamePostCount('game-5', 1); // Call of Duty
    await updateGamePostCount('game-6', 1); // Warzone
    await updateGamePostCount('game-7', 1); // Marvel Rivals
    
    print('Database seeding completed successfully!');
  }
}