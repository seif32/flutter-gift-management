class Gift {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String status;
  final String eventId;

  Gift({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.eventId,
  });

  // Convert Firestore data to Gift
  factory Gift.fromFirestore(Map<String, dynamic> data, String id) {
    return Gift(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? '',
      eventId: data['eventId'] ?? '',
    );
  }

  // Convert SQLite row data to Gift
  factory Gift.fromSQLite(Map<String, dynamic> data) {
    return Gift(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      price: (data['price'] as num).toDouble(),
      status: data['status'] as String,
      eventId: data['eventId'] as String,
    );
  }

  // Convert Gift to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'eventId': eventId,
    };
  }

  // Convert Gift to SQLite format
  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'eventId': eventId,
    };
  }
}
