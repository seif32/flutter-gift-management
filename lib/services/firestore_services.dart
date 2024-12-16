import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/app_user.dart';

import '../models/event.dart';
import '../models/gift.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<AppUser?> getUserByPhone(String phone) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final data = query.docs.first.data();
    return AppUser.fromFirestore(data, query.docs.first.id);
  }

  // Save Event
  static Future<void> saveEvent(Event event) async {
    await _firestore
        .collection('events')
        .doc(event.id)
        .set(event.toFirestore());
  }

  static Future<void> saveGift(Gift gift) async {
    final giftCollection = FirebaseFirestore.instance
        .collection('events')
        .doc(gift.eventId)
        .collection('gifts');
    await giftCollection.doc(gift.id).set(gift.toFirestore());
  }

  // Get Events for a User
  static Future<List<Event>> getUserEvents(String userId) async {
    final snapshot = await _firestore
        .collection('events')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => Event.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // Get Gifts for an Event
  static Future<List<Gift>> getGiftsForEvent(String eventId) async {
    final snapshot = await _firestore
        .collection('gifts')
        .where('eventId', isEqualTo: eventId)
        .get();

    return snapshot.docs
        .map((doc) => Gift.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // Add a friend in Firestore
  static Future<void> addFriend(
      String userId, String friendId, String status) async {
    final userDoc = _firestore.collection('users').doc(userId);
    final friendDoc = userDoc.collection('friends').doc(friendId);
    await friendDoc.set({
      'friendId': friendId,
      'status': status,
    });
  }

  // Retrieve all friends from Firestore
  static Future<List<Map<String, dynamic>>> getFriends(String userId) async {
    final userDoc = _firestore.collection('users').doc(userId);
    final friendsSnapshot = await userDoc.collection('friends').get();

    List<Map<String, dynamic>> friends = [];
    for (var doc in friendsSnapshot.docs) {
      final friendData = doc.data();
      friends.add({
        'friendId': friendData['friendId'],
        'status': friendData['status'],
      });
    }
    return friends;
  }

  /// Updates the status of a gift in Firestore.
  static Future<void> updateGiftStatus(
      String eventId, String giftId, String status) async {
    try {
      // Navigate to the nested structure for gifts
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Failed to update gift status: $e');
    }
  }
}
