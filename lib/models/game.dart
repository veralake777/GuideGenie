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
  
  // Factory constructor to create a Game from JSON
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      title: json['title'],
      genre: json['genre'],
      imageUrl: json['imageUrl'],
      rating: json['rating'].toDouble(),
      description: json['description'],
    );
  }
  
  // Method to convert a Game to JSON
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