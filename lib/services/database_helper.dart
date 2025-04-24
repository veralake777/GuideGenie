import 'dart:async';
import 'dart:io';
import 'package:guide_genie/models/comment.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/models/post.dart';
import 'package:guide_genie/models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  
  DatabaseHelper._internal();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'guide_genie.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create tables
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        bio TEXT,
        avatar_url TEXT,
        reputation INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        last_login TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE favorite_games (
        user_id TEXT,
        game_id TEXT,
        PRIMARY KEY (user_id, game_id),
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE games (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        cover_image_url TEXT NOT NULL,
        developer TEXT NOT NULL,
        publisher TEXT NOT NULL,
        release_date TEXT NOT NULL,
        rating REAL NOT NULL,
        post_count INTEGER NOT NULL,
        is_featured INTEGER NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE game_platforms (
        game_id TEXT,
        platform TEXT,
        PRIMARY KEY (game_id, platform),
        FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE game_genres (
        game_id TEXT,
        genre TEXT,
        PRIMARY KEY (game_id, genre),
        FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE posts (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        game_id TEXT NOT NULL,
        game_name TEXT NOT NULL,
        type TEXT NOT NULL,
        author_id TEXT NOT NULL,
        author_name TEXT NOT NULL,
        author_avatar_url TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        upvotes INTEGER NOT NULL,
        downvotes INTEGER NOT NULL,
        comment_count INTEGER NOT NULL,
        is_featured INTEGER NOT NULL,
        FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE,
        FOREIGN KEY (author_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE post_tags (
        post_id TEXT,
        tag TEXT,
        PRIMARY KEY (post_id, tag),
        FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE comments (
        id TEXT PRIMARY KEY,
        post_id TEXT NOT NULL,
        content TEXT NOT NULL,
        author_id TEXT NOT NULL,
        author_name TEXT NOT NULL,
        author_avatar_url TEXT NOT NULL,
        created_at TEXT NOT NULL,
        upvotes INTEGER NOT NULL,
        downvotes INTEGER NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE,
        FOREIGN KEY (author_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE user_votes (
        user_id TEXT,
        post_id TEXT,
        comment_id TEXT,
        is_upvote INTEGER NOT NULL,
        PRIMARY KEY (user_id, post_id, comment_id),
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE,
        FOREIGN KEY (comment_id) REFERENCES comments (id) ON DELETE CASCADE
      )
    ''');
  }
  
  // User operations
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'bio': user.bio,
        'avatar_url': user.avatarUrl,
        'reputation': user.reputation,
        'created_at': user.createdAt.toIso8601String(),
        'last_login': user.lastLogin?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Insert favorite games
    for (final gameId in user.favoriteGames) {
      await db.insert(
        'favorite_games',
        {
          'user_id': user.id,
          'game_id': gameId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
  
  Future<User?> getUser(String userId) async {
    final db = await database;
    final userMaps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    
    if (userMaps.isEmpty) {
      return null;
    }
    
    final favoriteGameMaps = await db.query(
      'favorite_games',
      columns: ['game_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    final favoriteGames = favoriteGameMaps.map((m) => m['game_id'] as String).toList();
    
    final userMap = userMaps.first;
    return User(
      id: userMap['id'] as String,
      username: userMap['username'] as String,
      email: userMap['email'] as String,
      bio: userMap['bio'] as String?,
      avatarUrl: userMap['avatar_url'] as String?,
      favoriteGames: favoriteGames,
      upvotedPosts: [], // TODO: Implement
      downvotedPosts: [], // TODO: Implement
      upvotedComments: [], // TODO: Implement
      downvotedComments: [], // TODO: Implement
      reputation: userMap['reputation'] as int,
      createdAt: DateTime.parse(userMap['created_at'] as String),
      lastLogin: DateTime.parse(userMap['last_login'] as String),
    );
  }
  
  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      {
        'username': user.username,
        'email': user.email,
        'bio': user.bio,
        'avatar_url': user.avatarUrl,
        'reputation': user.reputation,
        'last_login': user.lastLogin?.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
    
    // Update favorite games
    await db.delete(
      'favorite_games',
      where: 'user_id = ?',
      whereArgs: [user.id],
    );
    
    for (final gameId in user.favoriteGames) {
      await db.insert(
        'favorite_games',
        {
          'user_id': user.id,
          'game_id': gameId,
        },
      );
    }
  }
  
  Future<void> deleteUser(String userId) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
  
  // Game operations
  Future<void> insertGame(Game game) async {
    final db = await database;
    await db.insert(
      'games',
      {
        'id': game.id,
        'name': game.name,
        'description': game.description,
        'cover_image_url': game.coverImageUrl,
        'developer': game.developer,
        'publisher': game.publisher,
        'release_date': game.releaseDate,
        'rating': game.rating,
        'post_count': game.postCount,
        'is_featured': game.isFeatured ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Insert platforms
    for (final platform in game.platforms) {
      await db.insert(
        'game_platforms',
        {
          'game_id': game.id,
          'platform': platform,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    // Insert genres
    // for (final genre in game.genres) {
    //   await db.insert(
    //     'game_genres',
    //     {
    //       'game_id': game.id,
    //       'genre': genre,
    //     },
    //     conflictAlgorithm: ConflictAlgorithm.replace,
    //   );
    // }
  }
  
  Future<Game?> getGame(String gameId) async {
    final db = await database;
    final gameMaps = await db.query(
      'games',
      where: 'id = ?',
      whereArgs: [gameId],
    );
    
    if (gameMaps.isEmpty) {
      return null;
    }
    
    final platformMaps = await db.query(
      'game_platforms',
      columns: ['platform'],
      where: 'game_id = ?',
      whereArgs: [gameId],
    );
    
    final genreMaps = await db.query(
      'game_genres',
      columns: ['genre'],
      where: 'game_id = ?',
      whereArgs: [gameId],
    );
    
    final platforms = platformMaps.map((m) => m['platform'] as String).toList();
    final genres = genreMaps.map((m) => m['genre'] as String).toList();
    
    final gameMap = gameMaps.first;
    return Game(
      id: gameMap['id'] as String,
      name: gameMap['name'] as String,
      description: gameMap['description'] as String,
      coverImageUrl: gameMap['cover_image_url'] as String,
      // developer: gameMap['developer'] as String,
      // publisher: gameMap['publisher'] as String,
      // releaseDate: gameMap['release_date'] as String,
      // platforms: platforms,
      // genres: genres,
      rating: gameMap['rating'] as double,
      postCount: gameMap['post_count'] as int,
      isFeatured: (gameMap['is_featured'] as int) == 1, 
      iconUrl: '',
    );
  }
  
  Future<List<Game>> getAllGames() async {
    final db = await database;
    final gameMaps = await db.query('games');
    
    return await Future.wait(gameMaps.map((gameMap) async {
      final gameId = gameMap['id'] as String;
      
      final platformMaps = await db.query(
        'game_platforms',
        columns: ['platform'],
        where: 'game_id = ?',
        whereArgs: [gameId],
      );
      
      final genreMaps = await db.query(
        'game_genres',
        columns: ['genre'],
        where: 'game_id = ?',
        whereArgs: [gameId],
      );
      
      final platforms = platformMaps.map((m) => m['platform'] as String).toList();
      final genres = genreMaps.map((m) => m['genre'] as String).toList();
      
      return Game(
        id: gameId,
        name: gameMap['name'] as String,
        description: gameMap['description'] as String,
        coverImageUrl: gameMap['cover_image_url'] as String,
        // developer: gameMap['developer'] as String,
        // publisher: gameMap['publisher'] as String,
        // releaseDate: gameMap['release_date'] as String,
        // platforms: platforms,
        // genres: genres,
        rating: gameMap['rating'] as double,
        postCount: gameMap['post_count'] as int,
        isFeatured: (gameMap['is_featured'] as int) == 1,
        iconUrl: ''
      );
    }).toList());
  }
  
  Future<List<Game>> getFeaturedGames() async {
    final db = await database;
    final gameMaps = await db.query(
      'games',
      where: 'is_featured = ?',
      whereArgs: [1],
    );
    
    return await Future.wait(gameMaps.map((gameMap) async {
      final gameId = gameMap['id'] as String;
      
      final platformMaps = await db.query(
        'game_platforms',
        columns: ['platform'],
        where: 'game_id = ?',
        whereArgs: [gameId],
      );
      
      final genreMaps = await db.query(
        'game_genres',
        columns: ['genre'],
        where: 'game_id = ?',
        whereArgs: [gameId],
      );
      
      final platforms = platformMaps.map((m) => m['platform'] as String).toList();
      final genres = genreMaps.map((m) => m['genre'] as String).toList();
      
      return Game(
        id: gameId,
        name: gameMap['name'] as String,
        description: gameMap['description'] as String,
        coverImageUrl: gameMap['cover_image_url'] as String,
        // developer: gameMap['developer'] as String,
        // publisher: gameMap['publisher'] as String,
        // releaseDate: gameMap['release_date'] as String,
        // platforms: platforms,
        // genres: genres,
        rating: gameMap['rating'] as double,
        postCount: gameMap['post_count'] as int,
        isFeatured: true,
        iconUrl: ''
      );
    }).toList());
  }
  
  Future<void> updateGamePostCount(String gameId, int count) async {
    final db = await database;
    await db.update(
      'games',
      {'post_count': count},
      where: 'id = ?',
      whereArgs: [gameId],
    );
  }
  
  // Post operations
  Future<void> insertPost(Post post) async {
    final db = await database;
    await db.insert(
      'posts',
      {
        'id': post.id,
        'title': post.title,
        'content': post.content,
        'game_id': post.gameId,
        'game_name': post.gameName,
        'type': post.type,
        'author_id': post.authorId,
        'author_name': post.authorName,
        'author_avatar_url': post.authorAvatarUrl,
        'created_at': post.createdAt.toIso8601String(),
        'updated_at': post.updatedAt.toIso8601String(),
        'upvotes': post.upvotes,
        'downvotes': post.downvotes,
        'comment_count': post.commentCount,
        'is_featured': post.isFeatured ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Insert tags
    for (final tag in post.tags) {
      await db.insert(
        'post_tags',
        {
          'post_id': post.id,
          'tag': tag,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
  
  Future<Post?> getPost(String postId) async {
    final db = await database;
    final postMaps = await db.query(
      'posts',
      where: 'id = ?',
      whereArgs: [postId],
    );
    
    if (postMaps.isEmpty) {
      return null;
    }
    
    final tagMaps = await db.query(
      'post_tags',
      columns: ['tag'],
      where: 'post_id = ?',
      whereArgs: [postId],
    );
    
    final tags = tagMaps.map((m) => m['tag'] as String).toList();
    
    final postMap = postMaps.first;
    return Post(
      id: postMap['id'] as String,
      title: postMap['title'] as String,
      content: postMap['content'] as String,
      gameId: postMap['game_id'] as String,
      gameName: postMap['game_name'] as String,
      type: postMap['type'] as String,
      tags: tags,
      authorId: postMap['author_id'] as String,
      authorName: postMap['author_name'] as String,
      authorAvatarUrl: postMap['author_avatar_url'] as String,
      createdAt: DateTime.parse(postMap['created_at'] as String),
      updatedAt: DateTime.parse(postMap['updated_at'] as String),
      upvotes: postMap['upvotes'] as int,
      downvotes: postMap['downvotes'] as int,
      commentCount: postMap['comment_count'] as int,
      isFeatured: (postMap['is_featured'] as int) == 1,
    );
  }
  
  Future<List<Post>> getAllPosts() async {
    final db = await database;
    final postMaps = await db.query('posts');
    
    return await Future.wait(postMaps.map((postMap) async {
      final postId = postMap['id'] as String;
      
      final tagMaps = await db.query(
        'post_tags',
        columns: ['tag'],
        where: 'post_id = ?',
        whereArgs: [postId],
      );
      
      final tags = tagMaps.map((m) => m['tag'] as String).toList();
      
      return Post(
        id: postId,
        title: postMap['title'] as String,
        content: postMap['content'] as String,
        gameId: postMap['game_id'] as String,
        gameName: postMap['game_name'] as String,
        type: postMap['type'] as String,
        tags: tags,
        authorId: postMap['author_id'] as String,
        authorName: postMap['author_name'] as String,
        authorAvatarUrl: postMap['author_avatar_url'] as String,
        createdAt: DateTime.parse(postMap['created_at'] as String),
        updatedAt: DateTime.parse(postMap['updated_at'] as String),
        upvotes: postMap['upvotes'] as int,
        downvotes: postMap['downvotes'] as int,
        commentCount: postMap['comment_count'] as int,
        isFeatured: (postMap['is_featured'] as int) == 1,
      );
    }).toList());
  }
  
  Future<List<Post>> getFeaturedPosts() async {
    final db = await database;
    final postMaps = await db.query(
      'posts',
      where: 'is_featured = ?',
      whereArgs: [1],
    );
    
    return await Future.wait(postMaps.map((postMap) async {
      final postId = postMap['id'] as String;
      
      final tagMaps = await db.query(
        'post_tags',
        columns: ['tag'],
        where: 'post_id = ?',
        whereArgs: [postId],
      );
      
      final tags = tagMaps.map((m) => m['tag'] as String).toList();
      
      return Post(
        id: postId,
        title: postMap['title'] as String,
        content: postMap['content'] as String,
        gameId: postMap['game_id'] as String,
        gameName: postMap['game_name'] as String,
        type: postMap['type'] as String,
        tags: tags,
        authorId: postMap['author_id'] as String,
        authorName: postMap['author_name'] as String,
        authorAvatarUrl: postMap['author_avatar_url'] as String,
        createdAt: DateTime.parse(postMap['created_at'] as String),
        updatedAt: DateTime.parse(postMap['updated_at'] as String),
        upvotes: postMap['upvotes'] as int,
        downvotes: postMap['downvotes'] as int,
        commentCount: postMap['comment_count'] as int,
        isFeatured: true,
      );
    }).toList());
  }
  
  Future<List<Post>> getPostsByGame(String gameId) async {
    final db = await database;
    final postMaps = await db.query(
      'posts',
      where: 'game_id = ?',
      whereArgs: [gameId],
    );
    
    return await Future.wait(postMaps.map((postMap) async {
      final postId = postMap['id'] as String;
      
      final tagMaps = await db.query(
        'post_tags',
        columns: ['tag'],
        where: 'post_id = ?',
        whereArgs: [postId],
      );
      
      final tags = tagMaps.map((m) => m['tag'] as String).toList();
      
      return Post(
        id: postId,
        title: postMap['title'] as String,
        content: postMap['content'] as String,
        gameId: gameId,
        gameName: postMap['game_name'] as String,
        type: postMap['type'] as String,
        tags: tags,
        authorId: postMap['author_id'] as String,
        authorName: postMap['author_name'] as String,
        authorAvatarUrl: postMap['author_avatar_url'] as String,
        createdAt: DateTime.parse(postMap['created_at'] as String),
        updatedAt: DateTime.parse(postMap['updated_at'] as String),
        upvotes: postMap['upvotes'] as int,
        downvotes: postMap['downvotes'] as int,
        commentCount: postMap['comment_count'] as int,
        isFeatured: (postMap['is_featured'] as int) == 1,
      );
    }).toList());
  }
  
  Future<List<Post>> getPostsByUser(String userId) async {
    final db = await database;
    final postMaps = await db.query(
      'posts',
      where: 'author_id = ?',
      whereArgs: [userId],
    );
    
    return await Future.wait(postMaps.map((postMap) async {
      final postId = postMap['id'] as String;
      
      final tagMaps = await db.query(
        'post_tags',
        columns: ['tag'],
        where: 'post_id = ?',
        whereArgs: [postId],
      );
      
      final tags = tagMaps.map((m) => m['tag'] as String).toList();
      
      return Post(
        id: postId,
        title: postMap['title'] as String,
        content: postMap['content'] as String,
        gameId: postMap['game_id'] as String,
        gameName: postMap['game_name'] as String,
        type: postMap['type'] as String,
        tags: tags,
        authorId: userId,
        authorName: postMap['author_name'] as String,
        authorAvatarUrl: postMap['author_avatar_url'] as String,
        createdAt: DateTime.parse(postMap['created_at'] as String),
        updatedAt: DateTime.parse(postMap['updated_at'] as String),
        upvotes: postMap['upvotes'] as int,
        downvotes: postMap['downvotes'] as int,
        commentCount: postMap['comment_count'] as int,
        isFeatured: (postMap['is_featured'] as int) == 1,
      );
    }).toList());
  }
  
  Future<void> updatePostVotes(String postId, int upvotes, int downvotes) async {
    final db = await database;
    await db.update(
      'posts',
      {
        'upvotes': upvotes,
        'downvotes': downvotes,
      },
      where: 'id = ?',
      whereArgs: [postId],
    );
  }
  
  Future<void> updatePostCommentCount(String postId, int count) async {
    final db = await database;
    await db.update(
      'posts',
      {'comment_count': count},
      where: 'id = ?',
      whereArgs: [postId],
    );
  }
  
  // Comment operations
  Future<void> insertComment(Comment comment) async {
    final db = await database;
    await db.insert(
      'comments',
      {
        'id': comment.id,
        'post_id': comment.postId,
        'content': comment.content,
        'author_id': comment.authorId,
        'author_name': comment.authorName,
        'author_avatar_url': comment.authorAvatarUrl,
        'created_at': comment.createdAt.toIso8601String(),
        'upvotes': comment.upvotes,
        'downvotes': comment.downvotes,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Update post comment count
    final post = await getPost(comment.postId);
    if (post != null) {
      await updatePostCommentCount(comment.postId, post.commentCount + 1);
    }
  }
  
  Future<List<Comment>> getCommentsByPost(String postId) async {
    final db = await database;
    final commentMaps = await db.query(
      'comments',
      where: 'post_id = ?',
      whereArgs: [postId],
      orderBy: 'created_at DESC',
    );
    
    return commentMaps.map((commentMap) {
      return Comment(
        id: commentMap['id'] as String,
        postId: postId,
        content: commentMap['content'] as String,
        authorId: commentMap['author_id'] as String,
        authorName: commentMap['author_name'] as String,
        authorAvatarUrl: commentMap['author_avatar_url'] as String,
        createdAt: DateTime.parse(commentMap['created_at'] as String),
        upvotes: commentMap['upvotes'] as int,
        downvotes: commentMap['downvotes'] as int,
      );
    }).toList();
  }
  
  Future<void> updateCommentVotes(String commentId, int upvotes, int downvotes) async {
    final db = await database;
    await db.update(
      'comments',
      {
        'upvotes': upvotes,
        'downvotes': downvotes,
      },
      where: 'id = ?',
      whereArgs: [commentId],
    );
  }
  
  // Vote operations
  Future<void> saveVote(
    String userId,
    String? postId,
    String? commentId,
    bool isUpvote,
  ) async {
    assert(postId != null || commentId != null);
    
    final db = await database;
    await db.insert(
      'user_votes',
      {
        'user_id': userId,
        'post_id': postId ?? '',
        'comment_id': commentId ?? '',
        'is_upvote': isUpvote ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Update post or comment vote count
    if (postId != null) {
      final post = await getPost(postId);
      if (post != null) {
        await updatePostVotes(
          postId,
          isUpvote ? post.upvotes + 1 : post.upvotes,
          !isUpvote ? post.downvotes + 1 : post.downvotes,
        );
      }
    } else if (commentId != null) {
      final commentMaps = await db.query(
        'comments',
        where: 'id = ?',
        whereArgs: [commentId],
      );
      
      if (commentMaps.isNotEmpty) {
        final commentMap = commentMaps.first;
        await updateCommentVotes(
          commentId,
          isUpvote ? (commentMap['upvotes'] as int) + 1 : (commentMap['upvotes'] as int),
          !isUpvote ? (commentMap['downvotes'] as int) + 1 : (commentMap['downvotes'] as int),
        );
      }
    }
  }
  
  Future<List<String>> getUserVotedPosts(String userId, bool isUpvote) async {
    final db = await database;
    final voteMaps = await db.query(
      'user_votes',
      columns: ['post_id'],
      where: 'user_id = ? AND comment_id = "" AND is_upvote = ?',
      whereArgs: [userId, isUpvote ? 1 : 0],
    );
    
    return voteMaps.map((m) => m['post_id'] as String).toList();
  }
  
  Future<List<String>> getUserVotedComments(String userId, bool isUpvote) async {
    final db = await database;
    final voteMaps = await db.query(
      'user_votes',
      columns: ['comment_id'],
      where: 'user_id = ? AND post_id = "" AND is_upvote = ?',
      whereArgs: [userId, isUpvote ? 1 : 0],
    );
    
    return voteMaps.map((m) => m['comment_id'] as String).toList();
  }
  
  // Search operations
  Future<List<Game>> searchGames(String query) async {
    final db = await database;
    final searchQuery = '%$query%';
    final gameMaps = await db.query(
      'games',
      where: 'name LIKE ? OR description LIKE ? OR developer LIKE ? OR publisher LIKE ?',
      whereArgs: [searchQuery, searchQuery, searchQuery, searchQuery],
    );
    
    return await Future.wait(gameMaps.map((gameMap) async {
      final gameId = gameMap['id'] as String;
      
      final platformMaps = await db.query(
        'game_platforms',
        columns: ['platform'],
        where: 'game_id = ?',
        whereArgs: [gameId],
      );
      
      final genreMaps = await db.query(
        'game_genres',
        columns: ['genre'],
        where: 'game_id = ?',
        whereArgs: [gameId],
      );
      
      final platforms = platformMaps.map((m) => m['platform'] as String).toList();
      final genres = genreMaps.map((m) => m['genre'] as String).toList();
      
      return Game(
        id: gameId,
        name: gameMap['name'] as String,
        description: gameMap['description'] as String,
        coverImageUrl: gameMap['cover_image_url'] as String,
        // developer: gameMap['developer'] as String,
        // publisher: gameMap['publisher'] as String,
        // releaseDate: gameMap['release_date'] as String,
        // platforms: platforms,
        // genres: genres,
        rating: gameMap['rating'] as double,
        postCount: gameMap['post_count'] as int,
        isFeatured: (gameMap['is_featured'] as int) == 1,
        iconUrl: ''
      );
    }).toList());
  }
  
  Future<List<Post>> searchPosts(String query) async {
    final db = await database;
    final searchQuery = '%$query%';
    final postMaps = await db.query(
      'posts',
      where: 'title LIKE ? OR content LIKE ? OR game_name LIKE ? OR author_name LIKE ?',
      whereArgs: [searchQuery, searchQuery, searchQuery, searchQuery],
    );
    
    return await Future.wait(postMaps.map((postMap) async {
      final postId = postMap['id'] as String;
      
      final tagMaps = await db.query(
        'post_tags',
        columns: ['tag'],
        where: 'post_id = ?',
        whereArgs: [postId],
      );
      
      final tags = tagMaps.map((m) => m['tag'] as String).toList();
      
      return Post(
        id: postId,
        title: postMap['title'] as String,
        content: postMap['content'] as String,
        gameId: postMap['game_id'] as String,
        gameName: postMap['game_name'] as String,
        type: postMap['type'] as String,
        tags: tags,
        authorId: postMap['author_id'] as String,
        authorName: postMap['author_name'] as String,
        authorAvatarUrl: postMap['author_avatar_url'] as String,
        createdAt: DateTime.parse(postMap['created_at'] as String),
        updatedAt: DateTime.parse(postMap['updated_at'] as String),
        upvotes: postMap['upvotes'] as int,
        downvotes: postMap['downvotes'] as int,
        commentCount: postMap['comment_count'] as int,
        isFeatured: (postMap['is_featured'] as int) == 1,
      );
    }).toList());
  }
  
  // Additional search method for tags
  Future<List<Post>> searchPostsByTag(String tag) async {
    final db = await database;
    final tagMaps = await db.query(
      'post_tags',
      columns: ['post_id'],
      where: 'tag = ?',
      whereArgs: [tag],
    );
    
    final postIds = tagMaps.map((m) => m['post_id'] as String).toList();
    if (postIds.isEmpty) {
      return [];
    }
    
    final posts = <Post>[];
    for (final postId in postIds) {
      final post = await getPost(postId);
      if (post != null) {
        posts.add(post);
      }
    }
    
    return posts;
  }
}