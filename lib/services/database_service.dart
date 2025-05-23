import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/models/guide_post.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();
  
  PostgreSQLConnection? _connection;
  bool _isConnected = false;
  bool _useMockData = false;
  
  // Helper methods to determine data source
  bool get _shouldUseMockData {
    // Check direct mock data flag
    final useMockFlag = dotenv.env['USE_MOCK_DATA'] == 'true';
    
    // Check data source setting
    final dataSource = dotenv.env['DATA_SOURCE']?.toLowerCase();
    final useMockSource = dataSource == 'mock';
    
    // Check web environment flag
    final disableDbInWeb = dotenv.env['DISABLE_DATABASE_IN_WEB'] == 'true' && kIsWeb;
    
    print('DatabaseService: USE_MOCK_DATA=${useMockFlag}, DATA_SOURCE=${dataSource}, DISABLE_DATABASE_IN_WEB=${disableDbInWeb}');
    
    // Use mock data if any of these conditions are true
    return useMockFlag || useMockSource || disableDbInWeb;
  }
  
  // Override to force mock data mode
  void setMockDataMode(bool useMock) {
    _useMockData = useMock;
    
    // Save choice to environment
    dotenv.env['USE_MOCK_DATA'] = useMock.toString();
    dotenv.env['DATA_SOURCE'] = useMock ? 'mock' : 'database';
    
    print('DatabaseService: Manually set to ${useMock ? "MOCK" : "LIVE"} data mode');
    print('DatabaseService: Updated environment variables: USE_MOCK_DATA=${dotenv.env['USE_MOCK_DATA']}, DATA_SOURCE=${dotenv.env['DATA_SOURCE']}');
  }
  
  // General purpose method to execute SQL queries
  Future<List<Map<String, dynamic>>> executeSQL(String sql, {Map<String, dynamic>? substitutionValues}) async {
    if (_useMockData) {
      // Log SQL in mock mode
      print('Mock SQL: $sql');
      print('Mock Params: $substitutionValues');
      return [];
    }
    
    try {
      final results = await _executeDB((conn) async {
        return await conn.query(sql, substitutionValues: substitutionValues);
      });
      
      // Convert PostgreSQL results to List<Map<String, dynamic>>
      final mappedResults = <Map<String, dynamic>>[];
      for (final row in results) {
        final Map<String, dynamic> rowMap = {};
        for (int i = 0; i < results.columnDescriptions.length; i++) {
          final columnName = results.columnDescriptions[i].columnName;
          rowMap[columnName] = row[i];
        }
        mappedResults.add(rowMap);
      }
      
      return mappedResults;
    } catch (e) {
      print('Error executing SQL: $e');
      return [];
    }
  }
  
  // Connect to the database
  Future<void> connect() async {
    if (_isConnected) return;
    
    print('DatabaseService: Attempting to connect to database...');
    
    try {
      // Load environment variables
      await dotenv.load();
      
      // Check if we should use mock data
      if (_shouldUseMockData) {
        print('DatabaseService: Using mock data for development.');
        _useMockData = true;
        _isConnected = true; // Pretend we're connected
        return;
      }
      
      // Get individual connection parameters
      final host = dotenv.env['PGHOST'] ?? 'localhost';
      final port = int.tryParse(dotenv.env['PGPORT'] ?? '5432') ?? 5432;
      final database = dotenv.env['PGDATABASE'] ?? 'guidegenie';
      final username = dotenv.env['PGUSER'] ?? 'postgres';
      final password = dotenv.env['PGPASSWORD'] ?? 'postgres';
      
      // Create a new connection
      _connection = PostgreSQLConnection(
        host,
        port,
        database,
        username: username,
        password: password,
        useSSL: true,
      );
      
      // Open the connection
      await _connection!.open();
      
      // Test the connection
      await _connection!.query('SELECT 1');
      
      _isConnected = true;
      print('DatabaseService: Successfully connected to database');
    } catch (e) {
      print('DatabaseService: Error connecting to database: $e');
      _useMockData = true; // Fall back to mock data on error
      _isConnected = true; // Avoid further connection attempts
    }
  }
  
  // Execute a database operation with error handling
  Future<dynamic> _executeDB(
    Future<dynamic> Function(PostgreSQLConnection conn) dbOperation, 
    {dynamic defaultValue}
  ) async {
    await connect();
    
    if (_useMockData) {
      print('DatabaseService: Using mock data, skipping DB operation');
      return defaultValue;
    }
    
    if (_connection == null) {
      print('DatabaseService: Connection is null, cannot execute operation');
      return defaultValue;
    }
    
    try {
      // Execute the operation
      return await dbOperation(_connection!);
    } catch (e) {
      print('DatabaseService: Error executing operation: $e');
      return defaultValue;
    }
  }
  
  // Get all games
  Future<List<Game>> getAllGames() async {
    if (_useMockData) {
      return _getMockGames();
    }
    
    return await _executeDB((conn) async {
      final results = await conn.query('SELECT * FROM games ORDER BY title');
      
      return results.map((row) {
        return Game(
          id: row[0] as String,
          name: row[1] as String,  // Changed from title to name
          genre: row[2] as String,
          imageUrl: row[3] as String,
          iconUrl: row[3] as String,
          rating: (row[4] as num).toDouble(),
          description: row[5] as String,
        );
      }).toList();
    }, defaultValue: _getMockGames());
  }
  
  // Get a specific game by ID
  Future<Game?> getGameById(String id) async {
    if (_useMockData) {
      return _getMockGames().firstWhere(
        (game) => game.id == id,
        orElse: () => _getMockGames().first,
      );
    }
    
    return await _executeDB((conn) async {
      final results = await conn.query(
        'SELECT * FROM games WHERE id = @id',
        substitutionValues: {'id': id},
      );
      
      if (results.isEmpty) {
        return null;
      }
      
      final row = results.first;
      return Game(
        id: row[0] as String,
        name: row[1] as String,  // Changed from title to name
        genre: row[2] as String,
        imageUrl: row[3] as String,
        iconUrl: row[3] as String,
        rating: (row[4] as num).toDouble(),
        description: row[5] as String,
      );
    }, defaultValue: null);
  }
  
  // Get featured games
  Future<List<Game>> getFeaturedGames() async {
    if (_useMockData) {
      return _getMockGames().where((game) => game.isFeatured).toList();
    }
    
    return await _executeDB((conn) async {
      final results = await conn.query(
        'SELECT * FROM games WHERE is_featured = true ORDER BY title'
      );
      
      return results.map((row) {
        return Game(
          id: row[0] as String,
          name: row[1] as String,  // Changed from title to name
          genre: row[2] as String,
          imageUrl: row[3] as String,
          iconUrl: row[3] as String,
          rating: (row[4] as num).toDouble(),
          description: row[5] as String,
          isFeatured: true,
        );
      }).toList();
    }, defaultValue: []);
  }
  
  // Get popular games
  Future<List<Game>> getPopularGames() async {
    if (_useMockData) {
      final games = _getMockGames();
      games.sort((a, b) => b.rating.compareTo(a.rating));
      return games.take(5).toList();
    }
    
    return await _executeDB((conn) async {
      final results = await conn.query(
        'SELECT * FROM games ORDER BY rating DESC LIMIT 5'
      );
      
      return results.map((row) {
        return Game(
          id: row[0] as String,
          name: row[1] as String,  // Changed from title to name
          genre: row[2] as String,
          imageUrl: row[3] as String,
          iconUrl: row[3] as String,
          rating: (row[4] as num).toDouble(),
          description: row[5] as String,
        );
      }).toList();
    }, defaultValue: []);
  }
  
  // Get guides by game ID
  Future<List<GuidePost>> getGuidesByGame(String gameId) async {
    if (_useMockData) {
      return _getMockGuides().where((guide) => guide.gameId == gameId).toList();
    }
    
    return await _executeDB((conn) async {
      final results = await conn.query(
        'SELECT * FROM guides WHERE game_id = @gameId',
        substitutionValues: {'gameId': gameId},
      );
      
      return results.map((row) {
        return GuidePost(
          id: row[0] as String,
          title: row[1] as String,
          content: row[2] as String,
          type: row[3] as String,
          gameId: row[4] as String,
          gameName: row[5] as String,
          authorId: row[6] as String,
          authorName: row[7] as String,
          authorAvatarUrl: row[8] as String,
          createdAt: DateTime.parse(row[9] as String),
          updatedAt: DateTime.parse(row[10] as String),
          likes: row[11] as int,
          commentCount: row[12] as int,
          tags: (row[13] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
        );
      }).toList();
    }, defaultValue: []);
  }
  
  // Get guide by ID
  Future<GuidePost?> getGuideById(String id) async {
    if (_useMockData) {
      return _getMockGuides().firstWhere(
        (guide) => guide.id == id,
        orElse: () => _getMockGuides().first,
      );
    }
    
    return await _executeDB((conn) async {
      final results = await conn.query(
        'SELECT * FROM guides WHERE id = @id',
        substitutionValues: {'id': id},
      );
      
      if (results.isEmpty) {
        return null;
      }
      
      final row = results.first;
      return GuidePost(
        id: row[0] as String,
        title: row[1] as String,
        content: row[2] as String,
        type: row[3] as String,
        gameId: row[4] as String,
        gameName: row[5] as String,
        authorId: row[6] as String,
        authorName: row[7] as String,
        authorAvatarUrl: row[8] as String,
        createdAt: DateTime.parse(row[9] as String),
        updatedAt: DateTime.parse(row[10] as String),
        likes: row[11] as int,
        commentCount: row[12] as int,
        tags: (row[13] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      );
    }, defaultValue: null);
  }
  
  // Mock data for development
  List<Game> _getMockGames() {
    return [
      Game(
        id: '1',
        name: 'Fortnite',
        genre: 'Battle Royale',
        iconUrl: 'https://cdn2.unrealengine.com/en-22br-zerobuild-egs-launcher-2560x1440-2560x1440-a6f40c2ccea5.jpg',
        coverImageUrl: 'https://cdn2.unrealengine.com/en-22br-zerobuild-egs-launcher-2560x1440-2560x1440-a6f40c2ccea5.jpg',
        rating: 4.8,
        description: 'A battle royale game where 100 players fight to be the last person standing.',
        isFeatured: true,
        status: 'active',
        postCount: 25,
      ),
      Game(
        id: '2',
        name: 'League of Legends',
        genre: 'MOBA',
        iconUrl: 'https://www.leagueoflegends.com/static/open-graph-b580f0266cc3f0589d0dc10765bc1631.jpg',
        coverImageUrl: 'https://www.leagueoflegends.com/static/open-graph-b580f0266cc3f0589d0dc10765bc1631.jpg',
        rating: 4.5,
        description: 'A team-based strategy game where two teams of five champions face off to destroy the other\'s base.',
        isFeatured: true,
        status: 'active',
        postCount: 32,
      ),
      Game(
        id: '3',
        name: 'Valorant',
        genre: 'Tactical Shooter',
        iconUrl: 'https://images.contentstack.io/v3/assets/bltb6530b271fddd0b1/blt8f613797bb41494c/6532c95eed01b6526d104eed/Val_1000x563_Ep7-8_11x17.jpg',
        coverImageUrl: 'https://images.contentstack.io/v3/assets/bltb6530b271fddd0b1/blt8f613797bb41494c/6532c95eed01b6526d104eed/Val_1000x563_Ep7-8_11x17.jpg',
        rating: 4.6,
        description: 'A 5v5 character-based tactical shooter set on the global stage.',
        isFeatured: true,
        status: 'active',
        postCount: 19,
      ),
      Game(
        id: '4',
        name: 'Call of Duty: Warzone',
        genre: 'Battle Royale',
        iconUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/blog/hero/mw-wz/WZ-Season-Three-Announce-TOUT.jpg',
        coverImageUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/blog/hero/mw-wz/WZ-Season-Three-Announce-TOUT.jpg',
        rating: 4.3,
        description: 'A free-to-play battle royale game from the Call of Duty franchise.',
        isFeatured: false,
        status: 'active',
        postCount: 15,
      ),
      Game(
        id: '5',
        name: 'Street Fighter 6',
        genre: 'Fighting',
        iconUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/1364780/header.jpg',
        coverImageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/1364780/header.jpg',
        rating: 4.7,
        description: 'The newest entry in the legendary fighting game series.',
        isFeatured: true,
        status: 'active',
        postCount: 22,
      ),
      Game(
        id: '6',
        name: 'Marvel Rivals',
        genre: 'Hero Shooter',
        iconUrl: 'https://cdn1.epicgames.com/offer/c4763f236d08423eb47b4c3008779c84/EGS_MarvelRivals_NetEaseGames_S2_1200x1600-2187325a199bd9ef23bcbf5ac9210e2a',
        coverImageUrl: 'https://cdn1.epicgames.com/offer/c4763f236d08423eb47b4c3008779c84/EGS_MarvelRivals_NetEaseGames_S2_1200x1600-2187325a199bd9ef23bcbf5ac9210e2a',
        rating: 4.4,
        description: 'A team-based competitive 6v6 third-person super hero shooter set in a colliding Marvel universe.',
        isFeatured: true,
        status: 'active',
        postCount: 12,
      ),
    ];
  }
  
  List<GuidePost> _getMockGuides() {
    final now = DateTime.now();
    return [
      GuidePost(
        id: '101',
        title: 'Ultimate Beginner\'s Guide',
        content: 'Everything you need to know to get started. Learn the basics and get competitive quickly.',
        authorId: 'user1',
        authorName: 'GameGuru',
        authorAvatarUrl: '',
        gameId: '1',
        gameName: 'Fortnite',
        type: 'Guide',
        likes: 435,
        commentCount: 57,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 6)),
        tags: ['beginner', 'basics', 'tutorial'],
      ),
      GuidePost(
        id: '102',
        title: 'Current Meta Analysis',
        content: 'A breakdown of the current meta. Find out what strategies and loadouts are dominating.',
        authorId: 'user2',
        authorName: 'MetaMaster',
        authorAvatarUrl: '',
        gameId: '1',
        gameName: 'Fortnite',
        type: 'Meta',
        likes: 287,
        commentCount: 42,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 2)),
        tags: ['meta', 'analysis', 'tier-list'],
      ),
      GuidePost(
        id: '103',
        title: 'Advanced Tactics',
        content: 'Take your skills to the next level with these pro-level tactics and strategies.',
        authorId: 'user3',
        authorName: 'ProPlayer',
        authorAvatarUrl: '',
        gameId: '1',
        gameName: 'Fortnite',
        type: 'Strategy',
        likes: 198,
        commentCount: 29,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 4)),
        tags: ['advanced', 'tactics', 'pro-tips'],
      ),
      GuidePost(
        id: '104',
        title: 'Champion Selection Guide',
        content: 'How to choose the right champion for your playstyle and team composition.',
        authorId: 'user2',
        authorName: 'MetaMaster',
        authorAvatarUrl: '',
        gameId: '2',
        gameName: 'League of Legends',
        type: 'Guide',
        likes: 312,
        commentCount: 47,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 8)),
        tags: ['champion-select', 'team-comp', 'meta'],
      ),
      GuidePost(
        id: '105',
        title: 'Ultimate Fortnite Season X Weapon Tier List',
        content: 'A comprehensive tier list of all weapons in the current season, including stats and best uses.',
        authorId: 'user1',
        authorName: 'GameGuru',
        authorAvatarUrl: '',
        gameId: '1',
        gameName: 'Fortnite',
        type: 'Tier List',
        likes: 521,
        commentCount: 76,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
        tags: ['weapons', 'tier-list', 'meta'],
      ),
    ];
  }
}