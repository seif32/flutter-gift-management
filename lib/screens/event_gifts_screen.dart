import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift.dart';
import 'package:hedieaty/services/db_helper.dart';
import 'package:hedieaty/services/firestore_services.dart';
import 'add_gift_screen.dart';

class EventGiftsScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const EventGiftsScreen({
    required this.eventId,
    required this.eventName,
    Key? key,
  }) : super(key: key);

  @override
  State<EventGiftsScreen> createState() => _EventGiftsScreenState();
}

class _EventGiftsScreenState extends State<EventGiftsScreen> {
  late Future<List<Gift>> _giftsFuture;

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  void _loadGifts() {
    _giftsFuture = LocalDatabase.getGiftsForEvent(widget.eventId);
  }

  void _deleteGift(String giftId) async {
    try {
      await LocalDatabase.deleteGift(giftId);
      await FirestoreService.deleteGift(widget.eventId, giftId);
      setState(() {
        _loadGifts();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift deleted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete gift: $e')),
      );
    }
  }

  void _editGift(Gift gift) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (ctx) =>
                AddGiftScreen(eventId: widget.eventId, gift: gift),
          ),
        )
        .then((_) => _loadGifts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gifts for ${widget.eventName}')),
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
              final isPledged = gift.status == 'Pledged';

              return Card(
                color: isPledged
                    ? Colors.green[100]
                    : Colors.white, // Color-coded for pledged gifts
                child: ListTile(
                  title: Text(gift.name),
                  subtitle: Text(
                    'Category: ${gift.category} - Price: \$${gift.price} - Status: ${gift.status}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button (disabled for pledged gifts)
                      if (isPledged) const Icon(Icons.lock, color: Colors.grey),
                      if (!isPledged)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editGift(gift),
                            ),
                            // Delete button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteGift(gift.id),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (ctx) => AddGiftScreen(eventId: widget.eventId),
                ),
              )
              .then((_) => _loadGifts());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
