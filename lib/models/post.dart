enum GuideType {
  strategy,
  tierList,
  loadout,
  beginnerTips,
  advancedTips,
  metaAnalysis,
  update,
  news,
  other
}

class Post {
  final String id;
  final String title;
  final String content;
  final String gameId;
  final String gameName;
  final GuideType type;
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
    this.isFeatured = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      gameId: json['gameId'],
      gameName: json['gameName'],
      type: _parseGuideType(json['type']),
      tags: List<String>.from(json['tags']),
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorAvatarUrl: json['authorAvatarUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      upvotes: json['upvotes'],
      downvotes: json['downvotes'],
      commentCount: json['commentCount'],
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'gameId': gameId,
      'gameName': gameName,
      'type': type.toString().split('.').last,
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

  static GuideType _parseGuideType(String typeStr) {
    try {
      return GuideType.values.firstWhere(
        (type) => type.toString().split('.').last == typeStr,
      );
    } catch (e) {
      return GuideType.other;
    }
  }

  Post copyWith({
    String? id,
    String? title,
    String? content,
    String? gameId,
    String? gameName,
    GuideType? type,
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
      id: json['id'],
      postId: json['postId'],
      content: json['content'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorAvatarUrl: json['authorAvatarUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      upvotes: json['upvotes'],
      downvotes: json['downvotes'],
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