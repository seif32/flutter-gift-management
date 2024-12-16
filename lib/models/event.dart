class Event {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final String userId;
  final bool isPublished;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
    this.isPublished = false,
  });

  // Convert Firestore data to Event
  factory Event.fromFirestore(Map<String, dynamic> data, String id) {
    return Event(
      id: id,
      name: data['name'] ?? '',
      date: DateTime.parse(data['date']),
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      isPublished: data['isPublished'] ?? false,
    );
  }

  // Convert SQLite row data to Event
  factory Event.fromSQLite(Map<String, dynamic> data) {
    return Event(
      id: data['id'] as String,
      name: data['name'] as String,
      date: DateTime.parse(data['date'] as String),
      location: data['location'] as String,
      description: data['description'] as String,
      userId: data['userId'] as String,
      isPublished: (data['isPublished'] as int) ==
          1, // SQLite stores booleans as integers
    );
  }

  // Convert Event to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
      'userId': userId,
      'isPublished': isPublished,
    };
  }

  // Convert Event to SQLite format
  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
      'userId': userId,
      'isPublished':
          isPublished ? 1 : 0, // Convert boolean to integer for SQLite
    };
  }
}
