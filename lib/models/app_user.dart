class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl; // Optional property for the profile picture URL

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
  });

  // Convert Firestore data to AppUser
  factory AppUser.fromFirestore(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'], // Optional property
    );
  }

  // Convert AppUser to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
    };
  }

  // Convert SQLite row data to AppUser
  factory AppUser.fromSQLite(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'] as String,
      name: data['name'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String,
      photoUrl: data['photoUrl'] as String?, // Ensure it can handle null values
    );
  }

  // Convert AppUser to SQLite format
  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl, // Optional property
    };
  }
}
