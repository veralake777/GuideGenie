class User {
  final String id;
  final String username;
  final String email;
  final String? bio;
  final String? avatarUrl;
  final List<String> favoriteGames;
  final List<String> upvotedPosts;
  final List<String> downvotedPosts;
  final List<String> upvotedComments;
  final List<String> downvotedComments;
  final List<String> bookmarkedPosts; // Added for bookmarks feature
  final int reputation;
  final DateTime createdAt;
  final DateTime lastLogin;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.bio,
    this.avatarUrl,
    required this.favoriteGames,
    required this.upvotedPosts,
    required this.downvotedPosts,
    required this.upvotedComments,
    required this.downvotedComments,
    required this.bookmarkedPosts, // Added for bookmarks feature
    required this.reputation,
    required this.createdAt,
    required this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      favoriteGames: json['favoriteGames'] != null 
          ? List<String>.from(json['favoriteGames'] as List)
          : [],
      upvotedPosts: json['upvotedPosts'] != null 
          ? List<String>.from(json['upvotedPosts'] as List)
          : [],
      downvotedPosts: json['downvotedPosts'] != null 
          ? List<String>.from(json['downvotedPosts'] as List)
          : [],
      upvotedComments: json['upvotedComments'] != null 
          ? List<String>.from(json['upvotedComments'] as List)
          : [],
      downvotedComments: json['downvotedComments'] != null 
          ? List<String>.from(json['downvotedComments'] as List)
          : [],
      bookmarkedPosts: json['bookmarkedPosts'] != null 
          ? List<String>.from(json['bookmarkedPosts'] as List)
          : [],
      reputation: json['reputation'] as int? ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'favoriteGames': favoriteGames,
      'upvotedPosts': upvotedPosts,
      'downvotedPosts': downvotedPosts,
      'upvotedComments': upvotedComments,
      'downvotedComments': downvotedComments,
      'bookmarkedPosts': bookmarkedPosts,
      'reputation': reputation,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? bio,
    String? avatarUrl,
    List<String>? favoriteGames,
    List<String>? upvotedPosts,
    List<String>? downvotedPosts,
    List<String>? upvotedComments,
    List<String>? downvotedComments,
    int? reputation,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      favoriteGames: favoriteGames ?? this.favoriteGames,
      upvotedPosts: upvotedPosts ?? this.upvotedPosts,
      downvotedPosts: downvotedPosts ?? this.downvotedPosts,
      upvotedComments: upvotedComments ?? this.upvotedComments,
      downvotedComments: downvotedComments ?? this.downvotedComments,
      reputation: reputation ?? this.reputation,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}