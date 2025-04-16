import 'dart:async';
import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/models/post.dart';
import 'package:guide_genie/models/user.dart';

class PostgresDatabase {
  static final PostgresDatabase _instance = PostgresDatabase._internal();
  factory PostgresDatabase() => _instance;
  
  PostgresDatabase._internal();
  
  late PostgreSQLConnection _connection;
  bool _isConnected = false;
  
  Future<void> connect() async {
    if (_isConnected) return;
    
    final host = String.fromEnvironment('PGHOST', defaultValue: 'localhost');
    final port = int.parse(String.fromEnvironment('PGPORT', defaultValue: '5432'));
    final username = String.fromEnvironment('PGUSER', defaultValue: 'postgres');
    final password = String.fromEnvironment('PGPASSWORD', defaultValue: '');
    final database = String.fromEnvironment('PGDATABASE', defaultValue: 'guide_genie');
    
    _connection = PostgreSQLConnection(
      host,
      port, 
      database,
      username: username,
      password: password,
    );
    
    try {
      await _connection.open();
      _isConnected = true;
      await _createTables();
    } catch (e) {
      print('PostgreSQL connection error: $e');
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
      name: gameData[1] as String,
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
}