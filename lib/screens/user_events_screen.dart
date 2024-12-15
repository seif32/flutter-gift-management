import 'package:flutter/material.dart';
import 'package:hedieaty/screens/event_gifts_screen.dart';
import 'package:hedieaty/services/firestore_services.dart';
import '../models/event.dart';
import '../services/db_helper.dart';

class UserEventsScreen extends StatelessWidget {
  final String userId; // Pass the logged-in user ID

  const UserEventsScreen({required this.userId, Key? key}) : super(key: key);

  void _publishEvent(BuildContext context, Event event) async {
    try {
      // Step 1: Update isPublished to true locally
      final updatedEvent = Event(
        id: event.id,
        name: event.name,
        date: event.date,
        location: event.location,
        description: event.description,
        userId: event.userId,
        isPublished: true, // Set isPublished to true
      );

      await LocalDatabase.updateEvent(updatedEvent); // Update locally

      // Step 2: Sync updated event to the cloud
      await FirestoreService.saveEvent(updatedEvent);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event published successfully!')),
      );

      // Step 3: Refresh UI (optional, depends on the database listener)
      // You might need to trigger a refresh depending on how your local database is set up.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Events')),
      body: FutureBuilder<List<Event>>(
        future: LocalDatabase.getUserEvents(userId), // Get events from local DB
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events found.'));
          }
          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (ctx, index) {
              return ListTile(
                title: Text(events[index].name),
                subtitle: Text(events[index].location),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => EventGiftsScreen(
                        eventId: events[index].id,
                        eventName: events[index].name,
                      ),
                    ),
                  );
                },
                trailing: events[index].isPublished
                    ? const Icon(Icons.cloud_done, color: Colors.green)
                    : IconButton(
                        icon: const Icon(Icons.cloud_upload),
                        onPressed: () => _publishEvent(context, events[index]),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
