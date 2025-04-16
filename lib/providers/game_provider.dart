import 'package:flutter/material.dart';
import 'package:guide_genie/models/game.dart';
import 'package:guide_genie/services/api_service.dart';

class GameProvider with ChangeNotifier {
  List<Game> _games = [];
  List<Game> _featuredGames = [];
  Game? _selectedGame;
  bool _isLoading = false;
  String? _errorMessage;

  final ApiService _apiService = ApiService();

  List<Game> get games => _games;
  List<Game> get featuredGames => _featuredGames;
  Game? get selectedGame => _selectedGame;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize the game provider and load games
  GameProvider() {
    fetchGames();
  }

  // Fetch all games from the API
  Future<void> fetchGames() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final gamesData = await _apiService.getGames();
      _games = gamesData.map((game) => Game.fromJson(game)).toList();
      _featuredGames = _games.where((game) => game.isFeatured).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load games: ${e.toString()}';
      
      // In case of error, provide some sample games for testing
      // This will be removed when connecting to a real API
      _loadSampleGames();
      notifyListeners();
    }
  }

  // Get details for a specific game
  Future<void> fetchGameDetails(String gameId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final gameData = await _apiService.getGameDetails(gameId);
      _selectedGame = Game.fromJson(gameData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load game details: ${e.toString()}';
      
      // Find the game in the existing list if API call fails
      _selectedGame = _games.firstWhere(
        (game) => game.id == gameId,
        orElse: () => _games.first,
      );
      notifyListeners();
    }
  }

  // Load sample games for testing (will be removed later)
  void _loadSampleGames() {
    final currentTime = DateTime.now();
    final sampleGames = [
      Game(
        id: '1',
        name: 'Fortnite',
        shortDescription: 'Battle royale game with building mechanics',
        description: 'Fortnite is a popular battle royale game where players fight to be the last one standing while building structures for defense.',
        logoUrl: 'assets/game_logos/fortnite.svg',
        coverImageUrl: 'https://cdn2.unrealengine.com/fortnite-chapter-4-c4s3-1900x600-9a83898a6226.jpg',
        genres: ['Battle Royale', 'Shooter', 'Survival'],
        publisher: 'Epic Games',
        developer: 'Epic Games',
        releaseDate: '2017-07-25',
        platforms: ['PC', 'PlayStation', 'Xbox', 'Switch', 'Mobile'],
        rating: 4.5,
        postCount: 128,
        isFeatured: true,
      ),
      Game(
        id: '2',
        name: 'League of Legends',
        shortDescription: 'Competitive MOBA with diverse champions',
        description: 'League of Legends is a team-based strategy game where two teams of five powerful champions face off to destroy the other\'s base.',
        logoUrl: 'assets/game_logos/league_of_legends.svg',
        coverImageUrl: 'https://www.leagueoflegends.com/static/open-graph-2e582ae9fae8b0b396ca46ff21fd47a8.jpg',
        genres: ['MOBA', 'Strategy', 'Competitive'],
        publisher: 'Riot Games',
        developer: 'Riot Games',
        releaseDate: '2009-10-27',
        platforms: ['PC'],
        rating: 4.3,
        postCount: 156,
        isFeatured: true,
      ),
      Game(
        id: '3',
        name: 'Valorant',
        shortDescription: 'Tactical shooter with unique agent abilities',
        description: 'Valorant is a 5v5 tactical shooter where precise gunplay meets unique agent abilities. Creativity is your greatest weapon.',
        logoUrl: 'assets/game_logos/valorant.svg',
        coverImageUrl: 'https://images.contentstack.io/v3/assets/bltb6530b271fddd0b1/blt37ed143b1fb24436/607f997f8a780557b2c85334/4-27-21_EP2-3_Article_3_Banner.jpg',
        genres: ['Tactical Shooter', 'FPS', 'Competitive'],
        publisher: 'Riot Games',
        developer: 'Riot Games',
        releaseDate: '2020-06-02',
        platforms: ['PC'],
        rating: 4.4,
        postCount: 92,
        isFeatured: true,
      ),
      Game(
        id: '4',
        name: 'Street Fighter',
        shortDescription: 'Iconic 1v1 fighting game series',
        description: 'Street Fighter is a classic fighting game series known for its competitive gameplay and iconic characters like Ryu and Chun-Li.',
        logoUrl: 'assets/game_logos/street_fighter.svg',
        coverImageUrl: 'https://cdn.akamai.steamstatic.com/steam/apps/1364780/header.jpg',
        genres: ['Fighting', 'Arcade', 'Competitive'],
        publisher: 'Capcom',
        developer: 'Capcom',
        releaseDate: '1987-08-12',
        platforms: ['PC', 'PlayStation', 'Xbox', 'Switch', 'Arcade'],
        rating: 4.6,
        postCount: 78,
        isFeatured: false,
      ),
      Game(
        id: '5',
        name: 'Call of Duty',
        shortDescription: 'Popular first-person shooter franchise',
        description: 'Call of Duty is a first-person shooter franchise known for its intense multiplayer and cinematic single-player campaigns.',
        logoUrl: 'assets/game_logos/call_of_duty.svg',
        coverImageUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/mw2/meta-images/reveal/mw2-reveal-meta-share.jpg',
        genres: ['FPS', 'Action', 'Multiplayer'],
        publisher: 'Activision',
        developer: 'Various (Infinity Ward, Treyarch, Sledgehammer)',
        releaseDate: '2003-10-29',
        platforms: ['PC', 'PlayStation', 'Xbox'],
        rating: 4.2,
        postCount: 115,
        isFeatured: false,
      ),
      Game(
        id: '6',
        name: 'Warzone',
        shortDescription: 'Free-to-play battle royale Call of Duty experience',
        description: 'Call of Duty: Warzone is a free-to-play battle royale game where up to 150 players compete to be the last squad standing.',
        logoUrl: 'assets/game_logos/warzone.svg',
        coverImageUrl: 'https://www.callofduty.com/content/dam/atvi/callofduty/cod-touchui/blog/hero/mw-wz/WZ-Season-Three-Announce-TOUT.jpg',
        genres: ['Battle Royale', 'FPS', 'Free-to-Play'],
        publisher: 'Activision',
        developer: 'Infinity Ward, Raven Software',
        releaseDate: '2020-03-10',
        platforms: ['PC', 'PlayStation', 'Xbox'],
        rating: 4.0,
        postCount: 87,
        isFeatured: true,
      ),
      Game(
        id: '7',
        name: 'Marvel Rivals',
        shortDescription: 'Team-based hero shooter with Marvel characters',
        description: 'Marvel Rivals is a 6v6 hero shooter featuring iconic Marvel characters with unique abilities and team-based gameplay.',
        logoUrl: 'assets/game_logos/marvel_rivals.svg',
        coverImageUrl: 'https://cdn1.epicgames.com/offer/27db5b1f146b46139ef2b0c70a1464af/EGS_MarvelRivals_NetEaseGames_S2_1200x1600-22f164c25b94ba09f45dcc1e1f5490a9',
        genres: ['Hero Shooter', 'Team-Based', 'Action'],
        publisher: 'NetEase Games',
        developer: 'NetEase Games',
        releaseDate: '2023-07-12',
        platforms: ['PC', 'PlayStation', 'Xbox'],
        rating: 4.1,
        postCount: 42,
        isFeatured: true,
      ),
    ];
    
    _games = sampleGames;
    _featuredGames = _games.where((game) => game.isFeatured).toList();
  }

  // Search games by name
  List<Game> searchGames(String query) {
    if (query.isEmpty) {
      return _games;
    }
    return _games.where(
      (game) => game.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Filter games by genre
  List<Game> filterGamesByGenre(String genre) {
    if (genre.isEmpty) {
      return _games;
    }
    return _games.where(
      (game) => game.genres.any(
        (g) => g.toLowerCase() == genre.toLowerCase()
      )
    ).toList();
  }

  // Get the list of all available genres
  List<String> get allGenres {
    final Set<String> genres = {};
    for (final game in _games) {
      genres.addAll(game.genres);
    }
    return genres.toList()..sort();
  }
}