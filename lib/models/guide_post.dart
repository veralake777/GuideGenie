class GuidePost {
  final String id;
  final String title;
  final String description;
  final String author;
  final String gameId;
  final String type;
  final int likes;
  final int comments;
  final DateTime createdAt;
  final String content;
  
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
  
  // Factory constructor to create a GuidePost from JSON
  factory GuidePost.fromJson(Map<String, dynamic> json) {
    return GuidePost(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      author: json['author'],
      gameId: json['gameId'],
      type: json['type'],
      likes: json['likes'],
      comments: json['comments'],
      createdAt: DateTime.parse(json['createdAt']),
      content: json['content'],
    );
  }
  
  // Method to convert a GuidePost to JSON
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