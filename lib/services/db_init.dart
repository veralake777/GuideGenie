import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/services/database_service.dart';

class DatabaseInitializer {
  final DatabaseService _db = DatabaseService();
  
  // Initialize database with tables and seed data
  Future<void> initialize() async {
    print('DatabaseInitializer: Starting database initialization');
    
    try {
      // Connect to the database
      await _db.connect();
      
      // Create required tables
      await _createTables();
      
      // Add seed data
      await _seedData();
      
      print('DatabaseInitializer: Database initialization complete');
    } catch (e) {
      print('DatabaseInitializer: Error initializing database: $e');
    }
  }
  
  // Create database tables
  Future<void> _createTables() async {
    await _db.executeSQL('''
      CREATE TABLE IF NOT EXISTS games (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        genre TEXT NOT NULL,
        image_url TEXT,
        rating REAL DEFAULT 0,
        description TEXT,
        is_featured BOOLEAN DEFAULT FALSE
      )
    ''');
    
    await _db.executeSQL('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        bio TEXT,
        avatar_url TEXT,
        favorite_games TEXT,
        upvoted_posts TEXT,
        downvoted_posts TEXT,
        upvoted_comments TEXT,
        downvoted_comments TEXT,
        bookmarked_posts TEXT,
        reputation INTEGER DEFAULT 0,
        created_at TIMESTAMP NOT NULL,
        last_login TIMESTAMP NOT NULL
      )
    ''');
    
    await _db.executeSQL('''
      CREATE TABLE IF NOT EXISTS guides (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        game_id TEXT NOT NULL,
        game_name TEXT NOT NULL,
        guide_type TEXT NOT NULL,
        tags TEXT,
        author_id TEXT NOT NULL,
        author_name TEXT NOT NULL,
        author_avatar_url TEXT,
        created_at TIMESTAMP NOT NULL,
        updated_at TIMESTAMP NOT NULL,
        upvotes INTEGER DEFAULT 0,
        downvotes INTEGER DEFAULT 0,
        comment_count INTEGER DEFAULT 0,
        is_featured BOOLEAN DEFAULT FALSE,
        FOREIGN KEY (game_id) REFERENCES games(id),
        FOREIGN KEY (author_id) REFERENCES users(id)
      )
    ''');
    
    await _db.executeSQL('''
      CREATE TABLE IF NOT EXISTS comments (
        id TEXT PRIMARY KEY,
        guide_id TEXT NOT NULL,
        content TEXT NOT NULL,
        author_id TEXT NOT NULL,
        author_name TEXT NOT NULL,
        author_avatar_url TEXT,
        created_at TIMESTAMP NOT NULL,
        upvotes INTEGER DEFAULT 0,
        downvotes INTEGER DEFAULT 0,
        FOREIGN KEY (guide_id) REFERENCES guides(id),
        FOREIGN KEY (author_id) REFERENCES users(id)
      )
    ''');
  }
  
  // Add seed data
  Future<void> _seedData() async {
    // Add featured games
    await _addFeaturedGames();
    
    // Add sample users
    await _addSampleUsers();
    
    // Add sample guides
    await _addSampleGuides();
  }
  
  // Add featured games data
  Future<void> _addFeaturedGames() async {
    final featuredGames = [
      Game(
        id: '1',
        name: 'Fortnite',
        description: 'A free-to-play Battle Royale game with numerous game modes for every type of player.',
        iconUrl: 'https://cdn2.unrealengine.com/social-image-chapter4-3-1920x1080-d35912cc25ad.jpg',
        status: 'active',
        genre: 'Battle Royale',
        rating: 4.5,
        isFeatured: true,
        postCount: 25,
        coverImageUrl: 'https://cdn2.unrealengine.com/social-image-chapter4-3-1920x1080-d35912cc25ad.jpg',
      ),
      Game(
        id: '2',
        name: 'League of Legends',
        description: 'A team-based strategy game where two teams of five powerful champions face off to destroy the other\'s base.',
        iconUrl: 'https://cdn1.epicgames.com/offer/24b9b5e323bc40eea252a10cdd3b2f10/LOL_2560x1440-98749e0d718e82d27a084941939bc9d3',
        status: 'active',
        genre: 'MOBA',
        rating: 4.2,
        isFeatured: true,
        postCount: 32,
        coverImageUrl: 'https://cdn1.epicgames.com/offer/24b9b5e323bc40eea252a10cdd3b2f10/LOL_2560x1440-98749e0d718e82d27a084941939bc9d3',
      ),
      Game(
        id: '3',
        name: 'Valorant',
        description: 'A 5v5 character-based tactical shooter where precise gunplay meets unique agent abilities.',
        iconUrl: 'https://images.contentstack.io/v3/assets/bltb6530b271fddd0b1/blt5096c72b49deb73b/63b8a72f41ad232c35427f9a/Val_Ep_6_Art.jpg',
        status: 'active',
        genre: 'Tactical Shooter',
        rating: 4.3,
        isFeatured: true,
        postCount: 19,
        coverImageUrl: 'https://images.contentstack.io/v3/assets/bltb6530b271fddd0b1/blt5096c72b49deb73b/63b8a72f41ad232c35427f9a/Val_Ep_6_Art.jpg',
      ),
      Game(
        id: '4',
        name: 'Street Fighter 6',
        description: 'The newest entry in the legendary fighting game franchise with stunning visuals and new game modes.',
        iconUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/1364780/header.jpg',
        status: 'active',
        genre: 'Fighting',
        rating: 4.6,
        isFeatured: true,
        postCount: 15,
        coverImageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/1364780/header.jpg',
      ),
      Game(
        id: '5',
        name: 'Call of Duty: Modern Warfare III',
        description: 'The latest installment in the Call of Duty franchise featuring both multiplayer and campaign modes.',
        iconUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/blog/hero/mwiii/MWIII-REVEAL-FULL-TOUT.jpg',
        status: 'active',
        genre: 'FPS',
        rating: 4.0,
        isFeatured: true,
        postCount: 22,
        coverImageUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/blog/hero/mwiii/MWIII-REVEAL-FULL-TOUT.jpg',
      ),
      Game(
        id: '6',
        name: 'Warzone',
        description: 'Free-to-play Battle Royale experience from the Call of Duty universe.',
        iconUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/blog/hero/mwii/WZ2-S02-RELOADED-ANNOUNCE-TOUT.jpg',
        status: 'active',
        genre: 'Battle Royale',
        rating: 4.1,
        isFeatured: true,
        postCount: 28,
        coverImageUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/blog/hero/mwii/WZ2-S02-RELOADED-ANNOUNCE-TOUT.jpg',
      ),
      Game(
        id: '7',
        name: 'Marvel Rivals',
        description: 'A team-based third-person hero shooter set in the Marvel universe.',
        iconUrl: 'https://assetsio.gnwcdn.com/YE89zN6adbEVgRftvQrJN7.jpg',
        status: 'active',
        genre: 'Hero Shooter',
        rating: 4.4,
        isFeatured: true,
        postCount: 12,
        coverImageUrl: 'https://assetsio.gnwcdn.com/YE89zN6adbEVgRftvQrJN7.jpg',
      ),
    ];
    
    for (final game in featuredGames) {
      await _db.executeSQL(
        '''
        INSERT INTO games (id, title, genre, image_url, rating, description, is_featured)
        VALUES (@id, @name, @genre, @iconUrl, @rating, @description, TRUE)
        ON CONFLICT (id) DO UPDATE SET
          title = @name,
          genre = @genre,
          image_url = @iconUrl,
          rating = @rating,
          description = @description,
          is_featured = TRUE
        ''',
        substitutionValues: {
          'id': game.id,
          'name': game.name,
          'genre': game.genre,
          'iconUrl': game.iconUrl,
          'rating': game.rating,
          'description': game.description,
        },
      );
    }
  }
  
  // Add sample users
  Future<void> _addSampleUsers() async {
    // Add sample users if needed
    // Omitting for now as users are created dynamically
  }
  
  // Add sample guides
  Future<void> _addSampleGuides() async {
    // Add sample guides if needed
    // Omitting for now as guides are added by users
  }
}