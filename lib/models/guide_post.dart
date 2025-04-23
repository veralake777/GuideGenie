class GuidePost {
  final String id;
  final String title;
  final String type; // Guide, Meta, Tier List, Strategy, etc.
  final String content; // Markdown content for the guide
  final String gameId;
  final String gameName;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likes;
  final int commentCount;
  final List<String> tags;
  
  GuidePost({
    required this.id,
    required this.title,
    required this.type,
    required this.content,
    required this.gameId,
    required this.gameName,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl = '',
    required this.createdAt,
    DateTime? updatedAt,
    this.likes = 0,
    this.commentCount = 0,
    this.tags = const [],
  }) : updatedAt = updatedAt ?? createdAt;
  
  // Named constructor for creating from Post
  factory GuidePost.fromPost(Map<String, dynamic> post) {
    return GuidePost(
      id: post['id'] as String,
      title: post['title'] as String,
      type: post['type'] as String,
      content: post['content'] as String,
      gameId: post['gameId'] as String,
      gameName: post['gameName'] as String,
      authorId: post['authorId'] as String,
      authorName: post['authorName'] as String,
      authorAvatarUrl: post['authorAvatarUrl'] as String? ?? '',
      createdAt: post['createdAt'] is DateTime 
          ? post['createdAt'] as DateTime 
          : DateTime.parse(post['createdAt'] as String),
      updatedAt: post['updatedAt'] is DateTime 
          ? post['updatedAt'] as DateTime 
          : DateTime.parse(post['updatedAt'] as String),
      likes: post['upvotes'] as int? ?? 0,
      commentCount: post['commentCount'] as int? ?? 0,
      tags: (post['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
  
  // Named constructor for creating from JSON
  factory GuidePost.fromJson(Map<String, dynamic> json) {
    return GuidePost(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      content: json['content'] as String,
      gameId: json['gameId'] as String,
      gameName: json['gameName'] as String? ?? 'Unknown Game',
      authorId: json['authorId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? json['author'] as String? ?? 'Anonymous',
      authorAvatarUrl: json['authorAvatarUrl'] as String? ?? '',
      createdAt: json['createdAt'] is DateTime 
          ? json['createdAt'] as DateTime 
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] is DateTime 
          ? json['updatedAt'] as DateTime 
          : json['updatedAt'] != null 
              ? DateTime.parse(json['updatedAt'] as String) 
              : null,
      likes: json['likes'] as int? ?? json['upvotes'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? json['comments'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'content': content,
      'gameId': gameId,
      'gameName': gameName,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'likes': likes,
      'commentCount': commentCount,
      'tags': tags,
    };
  }
  
  // Create a copy with modified fields
  GuidePost copyWith({
    String? id,
    String? title,
    String? type,
    String? content,
    String? gameId,
    String? gameName,
    String? authorId,
    String? authorName,
    String? authorAvatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likes,
    int? commentCount,
    List<String>? tags,
  }) {
    return GuidePost(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      content: content ?? this.content,
      gameId: gameId ?? this.gameId,
      gameName: gameName ?? this.gameName,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      tags: tags ?? this.tags,
    );
  }
}