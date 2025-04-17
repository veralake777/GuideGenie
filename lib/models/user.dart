class User {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;
  final List<String> favoriteGames;
  final List<String> upvotedPosts;
  final List<String> downvotedPosts;
  final List<String> upvotedComments;
  final List<String> downvotedComments;
  final List<String> bookmarkedPosts;
  final int reputation;
  final DateTime? lastLogin;
  final String? bio;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.role = 'user',
    DateTime? createdAt,
    this.favoriteGames = const [],
    this.upvotedPosts = const [],
    this.downvotedPosts = const [],
    this.upvotedComments = const [],
    this.downvotedComments = const [],
    this.bookmarkedPosts = const [],
    this.reputation = 0,
    this.lastLogin,
    this.bio,
  }) : createdAt = createdAt ?? DateTime.now();

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'],
      role: map['role'] ?? 'user',
      createdAt: map['createdAt'] != null 
        ? (map['createdAt'] is DateTime 
            ? map['createdAt'] 
            : DateTime.parse(map['createdAt'])) 
        : DateTime.now(),
      favoriteGames: _parseStringList(map['favoriteGames']),
      upvotedPosts: _parseStringList(map['upvotedPosts']),
      downvotedPosts: _parseStringList(map['downvotedPosts']),
      upvotedComments: _parseStringList(map['upvotedComments']),
      downvotedComments: _parseStringList(map['downvotedComments']),
      bookmarkedPosts: _parseStringList(map['bookmarkedPosts']),
      reputation: map['reputation'] ?? 0,
      lastLogin: map['lastLogin'] != null 
        ? (map['lastLogin'] is DateTime 
            ? map['lastLogin'] 
            : DateTime.parse(map['lastLogin'])) 
        : null,
      bio: map['bio'],
    );
  }
  
  // Alias for fromMap to support JSON parsing
  factory User.fromJson(Map<String, dynamic> json) => User.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'favoriteGames': favoriteGames,
      'upvotedPosts': upvotedPosts,
      'downvotedPosts': downvotedPosts,
      'upvotedComments': upvotedComments,
      'downvotedComments': downvotedComments,
      'bookmarkedPosts': bookmarkedPosts,
      'reputation': reputation,
      'lastLogin': lastLogin?.toIso8601String(),
      'bio': bio,
    };
  }
  
  // Alias for toMap to support JSON serialization
  Map<String, dynamic> toJson() => toMap();

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    String? role,
    DateTime? createdAt,
    List<String>? favoriteGames,
    List<String>? upvotedPosts,
    List<String>? downvotedPosts,
    List<String>? upvotedComments,
    List<String>? downvotedComments,
    List<String>? bookmarkedPosts,
    int? reputation,
    DateTime? lastLogin,
    String? bio,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      favoriteGames: favoriteGames ?? this.favoriteGames,
      upvotedPosts: upvotedPosts ?? this.upvotedPosts,
      downvotedPosts: downvotedPosts ?? this.downvotedPosts,
      upvotedComments: upvotedComments ?? this.upvotedComments,
      downvotedComments: downvotedComments ?? this.downvotedComments,
      bookmarkedPosts: bookmarkedPosts ?? this.bookmarkedPosts,
      reputation: reputation ?? this.reputation,
      lastLogin: lastLogin ?? this.lastLogin,
      bio: bio ?? this.bio,
    );
  }
  
  // Helper method to parse string lists from Firestore
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }
}