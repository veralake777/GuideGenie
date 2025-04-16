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
      favoriteGames: (json['favoriteGames'] as List<dynamic>).cast<String>(),
      upvotedPosts: (json['upvotedPosts'] as List<dynamic>).cast<String>(),
      downvotedPosts: (json['downvotedPosts'] as List<dynamic>).cast<String>(),
      upvotedComments: (json['upvotedComments'] as List<dynamic>).cast<String>(),
      downvotedComments: (json['downvotedComments'] as List<dynamic>).cast<String>(),
      reputation: json['reputation'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: DateTime.parse(json['lastLogin'] as String),
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