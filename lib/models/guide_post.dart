class GuidePost {
  final String id;
  final String title;
  final String description;
  final String author;
  final String gameId;
  final String type; // Guide, Meta, Tier List, Strategy, etc.
  final int likes;
  final int comments;
  final DateTime createdAt;
  final String content; // Markdown content for the guide
  
  GuidePost({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.gameId,
    required this.type,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.content,
  });
  
  // Named constructor for creating from JSON
  factory GuidePost.fromJson(Map<String, dynamic> json) {
    return GuidePost(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      author: json['author'] as String,
      gameId: json['gameId'] as String,
      type: json['type'] as String,
      likes: json['likes'] as int,
      comments: json['comments'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      content: json['content'] as String,
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'gameId': gameId,
      'type': type,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt.toIso8601String(),
      'content': content,
    };
  }
}