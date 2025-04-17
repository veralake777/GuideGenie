class Guide {
  final String id;
  final String gameId;
  final String userId;
  final String title;
  final String content;
  final int upvotes;
  final int downvotes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Guide({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.title,
    required this.content,
    this.upvotes = 0,
    this.downvotes = 0,
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  factory Guide.fromMap(Map<String, dynamic> map) {
    return Guide(
      id: map['id'] ?? '',
      gameId: map['gameId'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      upvotes: map['upvotes'] ?? 0,
      downvotes: map['downvotes'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
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
      'gameId': gameId,
      'userId': userId,
      'title': title,
      'content': content,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Guide copyWith({
    String? id,
    String? gameId,
    String? userId,
    String? title,
    String? content,
    int? upvotes,
    int? downvotes,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Guide(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}