enum GameCategory {
  shooter,
  battleRoyale,
  moba,
  strategy,
  fighting,
  rpg,
  sports,
  racing,
  puzzle,
  cardGame,
  action,
  adventure,
}

class Game {
  final String id;
  final String name;
  final String description;
  final String coverImageUrl;
  final String developer;
  final String publisher;
  final String releaseDate;
  final List<String> platforms;
  final List<String> genres;
  final double rating;
  final int postCount;
  final bool isFeatured;

  Game({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImageUrl,
    required this.developer,
    required this.publisher,
    required this.releaseDate,
    required this.platforms,
    required this.genres,
    required this.rating,
    required this.postCount,
    required this.isFeatured,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      coverImageUrl: json['coverImageUrl'] as String,
      developer: json['developer'] as String,
      publisher: json['publisher'] as String,
      releaseDate: json['releaseDate'] as String,
      platforms: (json['platforms'] as List<dynamic>).cast<String>(),
      genres: (json['genres'] as List<dynamic>).cast<String>(),
      rating: json['rating'] as double,
      postCount: json['postCount'] as int,
      isFeatured: json['isFeatured'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'developer': developer,
      'publisher': publisher,
      'releaseDate': releaseDate,
      'platforms': platforms,
      'genres': genres,
      'rating': rating,
      'postCount': postCount,
      'isFeatured': isFeatured,
    };
  }

  Game copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImageUrl,
    String? developer,
    String? publisher,
    String? releaseDate,
    List<String>? platforms,
    List<String>? genres,
    double? rating,
    int? postCount,
    bool? isFeatured,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      developer: developer ?? this.developer,
      publisher: publisher ?? this.publisher,
      releaseDate: releaseDate ?? this.releaseDate,
      platforms: platforms ?? this.platforms,
      genres: genres ?? this.genres,
      rating: rating ?? this.rating,
      postCount: postCount ?? this.postCount,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}