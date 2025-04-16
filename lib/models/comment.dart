class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final int upvotes;
  final int downvotes;
  final String? parentCommentId; // For threaded comments
  final List<String> childCommentIds;

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.upvotes = 0,
    this.downvotes = 0,
    this.parentCommentId,
    this.childCommentIds = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['postId'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      parentCommentId: json['parentCommentId'] as String?,
      childCommentIds: List<String>.from(json['childCommentIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'upvotes': upvotes,
      'downvotes': downvotes,
      'parentCommentId': parentCommentId,
      'childCommentIds': childCommentIds,
    };
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? authorName,
    String? content,
    DateTime? createdAt,
    int? upvotes,
    int? downvotes,
    String? parentCommentId,
    List<String>? childCommentIds,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      childCommentIds: childCommentIds ?? this.childCommentIds,
    );
  }

  int get voteScore => upvotes - downvotes;
}
