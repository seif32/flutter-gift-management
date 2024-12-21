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

  // Delete an event
  static Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  static Future<void> saveGift(Gift gift) async {
    final giftCollection = FirebaseFirestore.instance
        .collection('events')
        .doc(gift.eventId)
        .collection('gifts');
    await giftCollection.doc(gift.id).set(gift.toFirestore());
  }

  // Method to delete a gift from Firestore
  static Future<void> deleteGift(String eventId, String giftId) async {
    try {
      await _firestore
          .collection('events') // Access the 'events' collection
          .doc(eventId) // Target the specific event document
          .collection('gifts') // Navigate to the nested 'gifts' subcollection
          .doc(giftId) // Target the specific gift document
          .delete(); // Perform the delete operation
    } catch (e) {
      throw Exception('Failed to delete gift: $e');
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

  static Future<List<Map<String, dynamic>>> getFriendsWithDetails(
      String userId) async {
    // Retrieve all friends where userId is either the user or friend
    final friendsSnapshot = await _firestore
        .collection('friends')
        .where('userId', isEqualTo: userId)
        .get();

    final reciprocalSnapshot = await _firestore
        .collection('friends')
        .where('friendId', isEqualTo: userId)
        .get();

    // Combine both snapshots for reciprocal relationships
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

      // Fetch the friend details
      final friendDoc =
          await _firestore.collection('users').doc(friendId).get();
      if (friendDoc.exists) {
        final friendDetails = friendDoc.data()!;
        // Fetch the number of events for the friend
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

  //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  static Future<List<Map<String, dynamic>>> getPledgedGiftsByUser(
      String loggedInUserId) async {
    List<Map<String, dynamic>> pledgedGifts = [];

    try {
      print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
      print('Start fetching pledged gifts for user: $loggedInUserId');
      print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

      // Step 1: Get all events
      final eventsSnapshot =
          await FirebaseFirestore.instance.collection('events').get();
      print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
      print('Fetched ${eventsSnapshot.docs.length} events from Firestore');
      print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

      // Parallel processing of events
      await Future.wait(eventsSnapshot.docs.map((eventDoc) async {
        final eventId = eventDoc.id;
        final eventData = eventDoc.data();

        print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        print('Processing event: $eventId');
        print('Event data: $eventData');
        print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

        // Extract eventDate and handle different data types
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

        // Query gifts for this event, filtered by status and pledgerId
        final giftsSnapshot = await eventDoc.reference
            .collection('gifts')
            .where('status', isEqualTo: 'Pledged')
            .where('pledgerId', isEqualTo: loggedInUserId)
            .get();

        print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        print(
            'Fetched ${giftsSnapshot.docs.length} gifts for event: $eventId that match loggedInUserId: $loggedInUserId');
        print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

        // Process each gift
        for (var giftDoc in giftsSnapshot.docs) {
          final giftData = giftDoc.data();

          print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
          print('Processing gift: ${giftDoc.id}');
          print('Gift data: $giftData');
          print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

          final pledgedGiftDetails = {
            ...giftData,
            'eventId': eventId,
            'eventName': eventData['name'],
            'eventDate': eventDate, // Use parsed date
            // ... other details
          };

          print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
          print('Pledged gift details: $pledgedGiftDetails');
          print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

          // Add to the list
          pledgedGifts.add(pledgedGiftDetails);
        }
      }));
    } catch (e) {
      print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
      print('Error fetching pledged gifts: $e');
      print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
      rethrow;
    }

    print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
    print('Final pledged gifts list: $pledgedGifts');
    print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');

    return pledgedGifts;
  }
}
