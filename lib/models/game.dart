class Game {
  final String id;
  final String title;
  final String genre;
  final String imageUrl;
  final double rating;
  final String description;
  
  Game({
    required this.id,
    required this.title,
    required this.genre,
    required this.imageUrl,
    required this.rating,
    required this.description,
  });
  
  // Named constructor for creating from JSON
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      title: json['title'] as String,
      genre: json['genre'] as String,
      imageUrl: json['imageUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      description: json['description'] as String,
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'genre': genre,
      'imageUrl': imageUrl,
      'rating': rating,
      'description': description,
    };
  }
}