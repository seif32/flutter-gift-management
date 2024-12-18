import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/services/firestore_services.dart';
import '../models/gift.dart';
import '../services/db_helper.dart';

class FriendGiftsListScreen extends StatelessWidget {
  final String eventId;
  final String eventName;

  final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;

  FriendGiftsListScreen({
    required this.eventId,
    required this.eventName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$eventName - Gifts")),
      body: FutureBuilder<List<Gift>>(
        future: LocalDatabase.getGiftsForEvent(eventId), // Fetch gifts by event
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No gifts found for this event.'));
          }
          final gifts = snapshot.data!;
          return ListView.builder(
            itemCount: gifts.length,
            itemBuilder: (ctx, index) {
              final gift = gifts[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(gift.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Description: ${gift.description}"),
                      Text("Category: ${gift.category}"),
                      Text("Price: \$${gift.price.toStringAsFixed(2)}"),
                      Text("Status: ${gift.status}"),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: gift.status == "Available"
                        ? () => _pledgeGift(context, gift)
                        : null,
                    child: const Text('Pledge'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _pledgeGift(BuildContext context, Gift gift) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pledge Gift'),
        content: Text('Are you sure you want to pledge "${gift.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      try {
        // Update status locally
        await LocalDatabase.updateGiftStatus(
          gift.id,
          'Pledged',
          loggedInUserId,
        );

        // Update status in Firestore (requires eventId and pledgerId)
        await FirestoreService.updateGiftStatus(
            gift.eventId, gift.id, 'Pledged', loggedInUserId);

        // Notify the user of success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You have pledged "${gift.name}".')),
        );
      } catch (e) {
        // Handle any errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pledge "${gift.name}": $e')),
        );
      }
    }
  }
}
