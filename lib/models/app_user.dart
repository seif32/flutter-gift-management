class AppUser {
  final String id;
  final String email;
  final String name;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
  });

  // Convert Firestore data to AppUser
  factory AppUser.fromFirestore(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
    );
  }

  // Convert SQLite row data to AppUser
  factory AppUser.fromSQLite(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'] as String,
      email: data['email'] as String,
      name: data['name'] as String,
    );
  }

  // Convert AppUser to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }

  // Convert AppUser to SQLite format
  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }
}
