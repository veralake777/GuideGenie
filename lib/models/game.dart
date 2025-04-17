class Game {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String status;

  Game({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.status,
  });

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconUrl: map['iconUrl'] ?? map['icon_url'] ?? '',
      status: map['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'status': status,
    };
  }

  Game copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    String? status,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      status: status ?? this.status,
    );
  }
}