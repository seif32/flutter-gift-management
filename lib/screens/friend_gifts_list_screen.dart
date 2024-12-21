import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/services/firestore_services.dart';
import '../models/gift.dart';
import '../services/db_helper.dart';

class FriendGiftsListScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  FriendGiftsListScreen({
    required this.eventId,
    required this.eventName,
    Key? key,
  }) : super(key: key);

  @override
  _FriendGiftsListScreenState createState() => _FriendGiftsListScreenState();
}

class _FriendGiftsListScreenState extends State<FriendGiftsListScreen> {
  final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;
  late Future<List<Gift>> _giftsFuture;

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  void _loadGifts() {
    setState(() {
      _giftsFuture = LocalDatabase.getGiftsForEvent(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.eventName} - Gifts")),
      body: FutureBuilder<List<Gift>>(
        future: _giftsFuture,
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
              final isAvailable = gift.status == "Available";

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: isAvailable ? Colors.white : Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gift.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Description: ${gift.description}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Category: ${gift.category}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Price: \$${gift.price.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Status: ${gift.status}",
                              style: TextStyle(
                                fontSize: 14,
                                color: isAvailable
                                    ? Colors.green[700]
                                    : Colors.grey[700],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: isAvailable
                                  ? () => _pledgeGift(context, gift)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                elevation: 3,
                                backgroundColor:
                                    isAvailable ? Colors.green : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                isAvailable ? "Pledge" : "Pledged",
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

        // Refresh gifts list
        _loadGifts();
      } catch (e) {
        // Handle any errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pledge "${gift.name}": $e')),
        );
      }
    }
  }
}
