class Comment {
  final String id;
  final String postId;
  final String content;
  final int upvotes;
  final int downvotes;
  final int authorId;
  final String authorName;
  final String? authorAvatar;
  final String? authorAvatarUrl;
  final String? parentCommentId;
  final List<String> childCommentIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.postId,
    required this.content,
    this.upvotes = 0,
    this.downvotes = 0,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.authorAvatarUrl,
    this.parentCommentId,
    this.childCommentIds = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      postId: map['postId'] ?? '',
      content: map['content'] ?? '',
      upvotes: map['upvotes'] ?? 0,
      downvotes: map['downvotes'] ?? 0,
      authorName: map['authorName'],
      authorAvatar: map['authorAvatar'],
      authorId: map['authorId'],
      authorAvatarUrl: map['authorAvatarUrl'],
      parentCommentId: map['parentCommentId'],
      childCommentIds: map['childCommentIds'] is List 
        ? List<String>.from(map['childCommentIds']) 
        : <String>[],
      createdAt: map['createdAt'] != null 
        ? (map['createdAt'] is DateTime 
            ? map['createdAt'] 
            : DateTime.parse(map['createdAt'])) 
        : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
        ? (map['updatedAt'] is DateTime 
            ? map['updatedAt'] 
            : DateTime.parse(map['updatedAt'])) 
        : DateTime.now(),
    );
  }

  // Alias for fromMap to support JSON parsing
  factory Comment.fromJson(Map<String, dynamic> json) => Comment.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'content': content,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'authorId': authorId,
      'authorAvatarUrl': authorAvatarUrl,
      'parentCommentId': parentCommentId,
      'childCommentIds': childCommentIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Alias for toMap to support JSON serialization
  Map<String, dynamic> toJson() => toMap();

  Comment copyWith({
    String? id,
    String? postId,
    String? content,
    int? upvotes,
    int? downvotes,
    String? authorName,
    String? authorAvatar,
    int? authorId,
    String? authorAvatarUrl,
    String? parentCommentId,
    List<String>? childCommentIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      authorId: authorId ?? this.authorId,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      childCommentIds: childCommentIds ?? this.childCommentIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}