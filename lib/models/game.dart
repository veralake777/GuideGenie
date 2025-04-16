enum GamePriority {
  p0, // Higher priority games
  p1, // Medium priority games
  p2, // Lower priority games
}

class Game {
  final String id;
  final String name;
  final String logoUrl;
  final GamePriority priority;
  final String? description;
  final String? currentVersion;
  final String? currentSeason;
  final List<String> categories; // For tagging system

  Game({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.priority,
    this.description,
    this.currentVersion,
    this.currentSeason,
    this.categories = const [],
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String,
      priority: _getPriorityFromString(json['priority'] as String),
      description: json['description'] as String?,
      currentVersion: json['currentVersion'] as String?,
      currentSeason: json['currentSeason'] as String?,
      categories: List<String>.from(json['categories'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'priority': priority.toString().split('.').last,
      'description': description,
      'currentVersion': currentVersion,
      'currentSeason': currentSeason,
      'categories': categories,
    };
  }

  static GamePriority _getPriorityFromString(String priorityStr) {
    switch (priorityStr.toLowerCase()) {
      case 'p0':
        return GamePriority.p0;
      case 'p1':
        return GamePriority.p1;
      case 'p2':
        return GamePriority.p2;
      default:
        return GamePriority.p1;
    }
  }
}
