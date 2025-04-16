class AppConstants {
  // API related
  static const String apiBaseUrl = 'https://guide-genie-api.example.com/api';
  
  // Game priorities description
  static const String p0Description = 'Popular Games';
  static const String p1Description = 'Competitive Games';
  static const String p2Description = 'Other Games';
  
  // Image assets
  static const String appLogoPath = 'assets/app_logo.svg';
  static const String gameLogosPath = 'assets/game_logos';
  
  // Default game categories
  static const List<String> defaultCategories = [
    'Guides',
    'Tips',
    'Strategies',
    'Tier Lists',
    'Loadouts',
    'Characters',
    'Maps',
  ];
  
  // P0 Games (Highest priority)
  static const List<String> p0Games = [
    'Fortnite',
    'League of Legends',
    'Valorant',
    'Street Fighter 6',
    'Call of Duty',
    'Call of Duty: Warzone',
    'Marvel Rivals',
  ];
  
  // P1 Games (Medium priority)
  static const List<String> p1Games = [
    'Apex Legends',
    'PUBG',
    'Overwatch',
    'Tekken 8',
    'DOTA 2',
    'Counter-Strike',
  ];
  
  // P2 Games (Lower priority)
  static const List<String> p2Games = [
    'Guilty Gear',
    'Hearthstone',
    'World of Warcraft',
    'Path of Exile',
    'Diablo',
  ];
  
  // Error messages
  static const String loginError = 'Failed to log in. Please check your credentials.';
  static const String registerError = 'Failed to register. Email might be already in use.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String loadGamesError = 'Failed to load games. Please try again.';
  static const String loadPostsError = 'Failed to load posts. Please try again.';
  static const String createPostError = 'Failed to create post. Please try again.';
  static const String voteError = 'Failed to register vote. Please try again.';
  
  // Form validations
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;
  static const String invalidEmailFormat = 'Please enter a valid email address';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String usernameTooShort = 'Username must be at least 3 characters';
  
  // Cached data keys
  static const String cachedGamesKey = 'cached_games';
  static const String cachedPostsPrefix = 'cached_posts_';
  static const String lastCacheTimeKey = 'last_cache_time';
  
  // Cache expiration in hours
  static const int cacheExpirationHours = 24;
}
