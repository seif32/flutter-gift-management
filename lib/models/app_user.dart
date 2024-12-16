class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  // Convert Firestore data to AppUser
  factory AppUser.fromFirestore(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
    );
  }

  // Convert SQLite row data to AppUser
  factory AppUser.fromSQLite(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String,
    );
  }

  // Convert AppUser to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  // Convert AppUser to SQLite format
  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}
