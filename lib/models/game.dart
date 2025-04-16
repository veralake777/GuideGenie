class Game {
  final String id;
  final String title; // Used in UI
  final String name; // Used in database
  final String genre; // Primary genre for UI
  final String description;
  final String imageUrl; // For UI display
  final String coverImageUrl; // For database
  final double rating;
  final String developer;
  final String publisher;
  final String releaseDate;
  final int postCount;
  final bool isFeatured;
  final List<String> platforms;
  final List<String> genres;
  
  Game({
    required this.id,
    required this.title,
    this.name = '',
    required this.genre,
    required this.imageUrl,
    this.coverImageUrl = '',
    required this.rating,
    required this.description,
    this.developer = '',
    this.publisher = '',
    this.releaseDate = '',
    this.postCount = 0,
    this.isFeatured = false,
    this.platforms = const [],
    this.genres = const [],
  });
  
  // Named constructor for creating from JSON
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      title: json['title'] as String? ?? json['name'] as String,
      name: json['name'] as String? ?? json['title'] as String,
      genre: json['genre'] as String? ?? (json['genres'] != null && (json['genres'] as List).isNotEmpty ? (json['genres'] as List)[0] as String : ''),
      imageUrl: json['imageUrl'] as String? ?? json['coverImageUrl'] as String? ?? '',
      coverImageUrl: json['coverImageUrl'] as String? ?? json['imageUrl'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      developer: json['developer'] as String? ?? '',
      publisher: json['publisher'] as String? ?? '',
      releaseDate: json['releaseDate'] as String? ?? '',
      postCount: json['postCount'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      platforms: json['platforms'] != null 
          ? List<String>.from(json['platforms'] as List)
          : const [],
      genres: json['genres'] != null 
          ? List<String>.from(json['genres'] as List)
          : const [],
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'name': name.isNotEmpty ? name : title,
      'genre': genre,
      'genres': genres,
      'imageUrl': imageUrl,
      'coverImageUrl': coverImageUrl.isNotEmpty ? coverImageUrl : imageUrl,
      'rating': rating,
      'description': description,
      'developer': developer,
      'publisher': publisher,
      'releaseDate': releaseDate,
      'postCount': postCount,
      'isFeatured': isFeatured,
      'platforms': platforms,
    };
  }
}