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
    List<String>? favoriteGames,
    List<String>? upvotedPosts,
    List<String>? downvotedPosts,
    List<String>? upvotedComments,
    List<String>? downvotedComments,
    this.reputation = 0,
    required this.createdAt,
    required this.lastLogin,
  }) : 
    favoriteGames = favoriteGames ?? [],
    upvotedPosts = upvotedPosts ?? [],
    downvotedPosts = downvotedPosts ?? [],
    upvotedComments = upvotedComments ?? [],
    downvotedComments = downvotedComments ?? [];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      bio: json['bio'],
      avatarUrl: json['avatarUrl'],
      favoriteGames: json['favoriteGames'] != null 
          ? List<String>.from(json['favoriteGames']) 
          : [],
      upvotedPosts: json['upvotedPosts'] != null 
          ? List<String>.from(json['upvotedPosts']) 
          : [],
      downvotedPosts: json['downvotedPosts'] != null 
          ? List<String>.from(json['downvotedPosts']) 
          : [],
      upvotedComments: json['upvotedComments'] != null 
          ? List<String>.from(json['upvotedComments']) 
          : [],
      downvotedComments: json['downvotedComments'] != null 
          ? List<String>.from(json['downvotedComments']) 
          : [],
      reputation: json['reputation'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin']) 
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