class Post {
  final String id;
  final String gameId;
  final String title;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final String content;
  final List<String> mediaUrls;
  final List<String> tags;
  final int upvotes;
  final int downvotes;
  final List<String> commentIds;
  final Map<String, dynamic>? metadata; // For game-specific data like tier lists

  Post({
    required this.id,
    required this.gameId,
    required this.title,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.content,
    this.mediaUrls = const [],
    this.tags = const [],
    this.upvotes = 0,
    this.downvotes = 0,
    this.commentIds = const [],
    this.metadata,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      title: json['title'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      content: json['content'] as String,
      mediaUrls: List<String>.from(json['mediaUrls'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      commentIds: List<String>.from(json['commentIds'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'title': title,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'content': content,
      'mediaUrls': mediaUrls,
      'tags': tags,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'commentIds': commentIds,
      'metadata': metadata,
    };
  }

  Post copyWith({
    String? id,
    String? gameId,
    String? title,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    String? content,
    List<String>? mediaUrls,
    List<String>? tags,
    int? upvotes,
    int? downvotes,
    List<String>? commentIds,
    Map<String, dynamic>? metadata,
  }) {
    return Post(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      title: title ?? this.title,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      tags: tags ?? this.tags,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      commentIds: commentIds ?? this.commentIds,
      metadata: metadata ?? this.metadata,
    );
  }

  int get voteScore => upvotes - downvotes;
}
