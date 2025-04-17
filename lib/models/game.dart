class Game {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String imageUrl;
  final String coverImageUrl;
  final String status;
  final String genre;
  final double rating;
  final bool isFeatured;
  final int postCount;
  
  // For backward compatibility
  String get title => name;

  Game({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    this.imageUrl = '',
    this.coverImageUrl = '',
    this.status = 'active',
    this.genre = '',
    this.rating = 0.0,
    this.isFeatured = false,
    this.postCount = 0,
  });

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] ?? '',
      name: map['name'] ?? map['title'] ?? '',
      description: map['description'] ?? '',
      iconUrl: map['iconUrl'] ?? map['icon_url'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      coverImageUrl: map['coverImageUrl'] ?? '',
      status: map['status'] ?? 'active',
      genre: map['genre'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      isFeatured: map['isFeatured'] ?? map['status'] == 'active',
      postCount: map['postCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'imageUrl': imageUrl,
      'coverImageUrl': coverImageUrl,
      'status': status,
      'genre': genre,
      'rating': rating,
      'isFeatured': isFeatured,
      'postCount': postCount,
    };
  }

  Game copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    String? imageUrl,
    String? coverImageUrl,
    String? status,
    String? genre,
    double? rating,
    bool? isFeatured,
    int? postCount,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      status: status ?? this.status,
      genre: genre ?? this.genre,
      rating: rating ?? this.rating,
      isFeatured: isFeatured ?? this.isFeatured,
      postCount: postCount ?? this.postCount,
    );
  }
}