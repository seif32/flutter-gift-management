class Friend {
  final String id;
  final String userId;
  final String friendId;

  Friend({
    required this.id,
    required this.userId,
    required this.friendId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
    };
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      userId: map['userId'],
      friendId: map['friendId'],
    );
  }

  // Method to convert Friend object to SQLite-compatible map
  Map<String, dynamic> toSql() {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
    };
  }

  // Method to create a Friend object from SQLite map
  factory Friend.fromSql(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      userId: map['userId'],
      friendId: map['friendId'],
    );
  }

  // Method to convert Friend object to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
    };
  }

  // Method to create a Friend object from Firestore document snapshot
  factory Friend.fromFirestore(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      userId: map['userId'],
      friendId: map['friendId'],
    );
  }
}
