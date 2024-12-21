import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/app_user.dart';

import '../models/event.dart';
import '../models/gift.dart';

class FirestoreService {
  static final _firestore = FirebaseFirestore.instance;

  // ######################################## Users Collection ########################################

  static Future<void> saveUser(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
      });
    } catch (e) {
      print('Error saving user: $e');
      throw e;
    }
  }

  static Future<AppUser> getUserById(String currentUserId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(currentUserId).get();
      if (doc.exists) {
        return AppUser(
          id: doc.id,
          name: doc['name'],
          email: doc['email'],
          phone: doc['phone'],
        );
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error getting user: $e');
      throw e;
    }
  }

  // ######################################## Events Collection ########################################

  // Save Event
  static Future<void> saveEvent(Event event) async {
    await _firestore
        .collection('events')
        .doc(event.id)
        .set(event.toFirestore());
  }

  // Delete an event
  static Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
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

  // ######################################## Gifts Sub-Collection ########################################

  static Future<void> saveGift(Gift gift) async {
    final giftCollection = FirebaseFirestore.instance
        .collection('events')
        .doc(gift.eventId)
        .collection('gifts');
    await giftCollection.doc(gift.id).set(gift.toFirestore());
  }

  // Delete a gift
  static Future<void> deleteGift(String eventId, String giftId) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete gift: $e');
    }
  }

  static Future<void> updateGiftStatus(
      String eventId, String giftId, String status, String pledgerId) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .update({
        'status': status,
        'pledgerId': pledgerId,
      });
    } catch (e) {
      throw Exception('Failed to update gift status: $e');
    }
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

  static Future<List<Map<String, dynamic>>> getPledgedGiftsByUser(
      String loggedInUserId) async {
    List<Map<String, dynamic>> pledgedGifts = [];

    try {
      final eventsSnapshot =
          await FirebaseFirestore.instance.collection('events').get();

      await Future.wait(eventsSnapshot.docs.map((eventDoc) async {
        final eventId = eventDoc.id;
        final eventData = eventDoc.data();

        DateTime? eventDate;
        try {
          if (eventData['date'] is Timestamp) {
            eventDate = (eventData['date'] as Timestamp).toDate();
          } else if (eventData['date'] is String) {
            eventDate = DateTime.parse(eventData['date']);
          }
        } catch (e) {
          print('Error parsing event date for event: $eventId');
          print('Event date: ${eventData['date']}');
          print('Error: $e');
          eventDate = null;
        }

        final giftsSnapshot = await eventDoc.reference
            .collection('gifts')
            .where('status', isEqualTo: 'Pledged')
            .where('pledgerId', isEqualTo: loggedInUserId)
            .get();

        for (var giftDoc in giftsSnapshot.docs) {
          final giftData = giftDoc.data();

          final pledgedGiftDetails = {
            ...giftData,
            'eventId': eventId,
            'eventName': eventData['name'],
            'eventDate': eventDate,
          };

          pledgedGifts.add(pledgedGiftDetails);
        }
      }));
    } catch (e) {
      print('Error fetching pledged gifts: $e');
      rethrow;
    }

    return pledgedGifts;
  }

// ######################################## Friends Collection ########################################

  static Future<void> addFriend(String currentUserId, String friendId) async {
    try {
      await _firestore.collection('friends').add({
        'userId': currentUserId,
        'friendId': friendId,
      });
    } catch (e) {
      print('Error adding friend: $e');
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> getFriendsWithDetails(
      String userId) async {
    final friendsSnapshot = await _firestore
        .collection('friends')
        .where('userId', isEqualTo: userId)
        .get();

    final reciprocalSnapshot = await _firestore
        .collection('friends')
        .where('friendId', isEqualTo: userId)
        .get();

    final allFriendsDocs = [
      ...friendsSnapshot.docs,
      ...reciprocalSnapshot.docs
    ];

    List<Map<String, dynamic>> friends = [];
    for (var doc in allFriendsDocs) {
      final friendData = doc.data();
      final friendId = friendData['userId'] == userId
          ? friendData['friendId']
          : friendData['userId'];

      final friendDoc =
          await _firestore.collection('users').doc(friendId).get();
      if (friendDoc.exists) {
        final friendDetails = friendDoc.data()!;
        final eventsSnapshot = await _firestore
            .collection('events')
            .where('userId', isEqualTo: friendId)
            .where('isPublished', isEqualTo: true)
            .get();

        friends.add({
          'id': friendId,
          'name': friendDetails['name'],
          'email': friendDetails['email'],
          'profilePicture': friendDetails['profilePicture'],
          'eventCount': eventsSnapshot.docs.length,
        });
      }
    }

    return friends;
  }
}
