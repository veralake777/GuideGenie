// Guide types are now implemented as strings in AppConstants.guideTypeNames
// Rather than an enum, we just use the string directly (e.g., 'strategy', 'tierList', etc.)

class Post {
  final String id;
  final String title;
  final String content;
  final String gameId;
  final String gameName;
  final String type;
  final List<String> tags;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int upvotes;
  final int downvotes;
  final int commentCount;
  final bool isFeatured;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.gameId,
    required this.gameName,
    required this.type,
    required this.tags,
    required this.authorId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.upvotes,
    required this.downvotes,
    required this.commentCount,
    required this.isFeatured,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      gameId: json['gameId'] as String,
      gameName: json['gameName'] as String,
      type: json['type'] as String,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorAvatarUrl: json['authorAvatarUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      upvotes: json['upvotes'] as int,
      downvotes: json['downvotes'] as int,
      commentCount: json['commentCount'] as int,
      isFeatured: json['isFeatured'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'gameId': gameId,
      'gameName': gameName,
      'type': type,
      'tags': tags,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'upvotes': upvotes,
      'downvotes': downvotes,
      'commentCount': commentCount,
      'isFeatured': isFeatured,
    };
  }

  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? gameId,
    String? gameName,
    String? type,
    List<String>? tags,
    String? authorId,
    String? authorName,
    String? authorAvatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? upvotes,
    int? downvotes,
    int? commentCount,
    bool? isFeatured,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      gameId: gameId ?? this.gameId,
      gameName: gameName ?? this.gameName,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      commentCount: commentCount ?? this.commentCount,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}

class Comment {
  final String id;
  final String postId;
  final String content;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final DateTime createdAt;
  final int upvotes;
  final int downvotes;

  Comment({
    required this.id,
    required this.postId,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.createdAt,
    required this.upvotes,
    required this.downvotes,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['postId'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorAvatarUrl: json['authorAvatarUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      upvotes: json['upvotes'] as int,
      downvotes: json['downvotes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'upvotes': upvotes,
      'downvotes': downvotes,
    };
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? content,
    String? authorId,
    String? authorName,
    String? authorAvatarUrl,
    DateTime? createdAt,
    int? upvotes,
    int? downvotes,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      createdAt: createdAt ?? this.createdAt,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
    );
  }
}