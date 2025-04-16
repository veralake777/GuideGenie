class User {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;
  final List<String> upvotedPosts;
  final List<String> downvotedPosts;
  final List<String> upvotedComments;
  final List<String> downvotedComments;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
    this.upvotedPosts = const [],
    this.downvotedPosts = const [],
    this.upvotedComments = const [],
    this.downvotedComments = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      upvotedPosts: List<String>.from(json['upvotedPosts'] ?? []),
      downvotedPosts: List<String>.from(json['downvotedPosts'] ?? []),
      upvotedComments: List<String>.from(json['upvotedComments'] ?? []),
      downvotedComments: List<String>.from(json['downvotedComments'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'upvotedPosts': upvotedPosts,
      'downvotedPosts': downvotedPosts,
      'upvotedComments': upvotedComments,
      'downvotedComments': downvotedComments,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    List<String>? upvotedPosts,
    List<String>? downvotedPosts,
    List<String>? upvotedComments,
    List<String>? downvotedComments,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      upvotedPosts: upvotedPosts ?? this.upvotedPosts,
      downvotedPosts: downvotedPosts ?? this.downvotedPosts,
      upvotedComments: upvotedComments ?? this.upvotedComments,
      downvotedComments: downvotedComments ?? this.downvotedComments,
    );
  }
}
