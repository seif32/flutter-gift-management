import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event.dart';
import '../models/gift.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;

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
}
