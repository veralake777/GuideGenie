class Comment {
  final String id;
  final String guideId;
  final String userId;
  final String postId;
  final String content;
  final int upvotes;
  final int downvotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? authorName;
  final String? authorAvatar;

  Comment({
    required this.id,
    required this.guideId,
    required this.userId,
    required this.content,
    this.postId = '',
    this.upvotes = 0,
    this.downvotes = 0,
    this.authorName,
    this.authorAvatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      guideId: map['guideId'] ?? '',
      userId: map['userId'] ?? '',
      postId: map['postId'] ?? '',
      content: map['content'] ?? '',
      upvotes: map['upvotes'] ?? 0,
      downvotes: map['downvotes'] ?? 0,
      authorName: map['authorName'],
      authorAvatar: map['authorAvatar'],
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
      'guideId': guideId,
      'userId': userId,
      'postId': postId,
      'content': content,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Alias for toMap to support JSON serialization
  Map<String, dynamic> toJson() => toMap();

  Comment copyWith({
    String? id,
    String? guideId,
    String? userId,
    String? postId,
    String? content,
    int? upvotes,
    int? downvotes,
    String? authorName,
    String? authorAvatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      guideId: guideId ?? this.guideId,
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}