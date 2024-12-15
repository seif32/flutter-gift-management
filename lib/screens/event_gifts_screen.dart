import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift.dart';
import 'package:hedieaty/services/db_helper.dart';
import 'add_gift_screen.dart';

class EventGiftsScreen extends StatelessWidget {
  final String eventId;
  final String eventName;

  const EventGiftsScreen(
      {required this.eventId, required this.eventName, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gifts for $eventName')),
      body: FutureBuilder<List<Gift>>(
        future: LocalDatabase.getGiftsForEvent(
            eventId), // Fetch gifts from the local DB
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
              return ListTile(
                title: Text(gifts[index].name),
                subtitle: Text(
                    'Category: ${gifts[index].category} - Price: \$${gifts[index].price}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => AddGiftScreen(eventId: eventId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
