class Comment {
  final String id;
  final String guideId;
  final String userId;
  final String content;
  final int upvotes;
  final int downvotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.guideId,
    required this.userId,
    required this.content,
    this.upvotes = 0,
    this.downvotes = 0,
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
      content: map['content'] ?? '',
      upvotes: map['upvotes'] ?? 0,
      downvotes: map['downvotes'] ?? 0,
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guideId': guideId,
      'userId': userId,
      'content': content,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Comment copyWith({
    String? id,
    String? guideId,
    String? userId,
    String? content,
    int? upvotes,
    int? downvotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      guideId: guideId ?? this.guideId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}