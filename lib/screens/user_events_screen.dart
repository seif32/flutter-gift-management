import 'package:flutter/material.dart';
import 'package:hedieaty/screens/add_event_screen.dart';
import 'package:hedieaty/screens/event_gifts_screen.dart';
import 'package:hedieaty/services/firestore_services.dart';
import '../models/event.dart';
import '../services/db_helper.dart';

class UserEventsScreen extends StatefulWidget {
  final String userId;

  const UserEventsScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _UserEventsScreenState createState() => _UserEventsScreenState();
}

class _UserEventsScreenState extends State<UserEventsScreen> {
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _refreshEvents();
  }

  void _refreshEvents() {
    setState(() {
      _eventsFuture = LocalDatabase.getUserEvents(widget.userId);
    });
  }

  void _publishEvent(BuildContext context, Event event) async {
    try {
      final updatedEvent = Event(
        id: event.id,
        name: event.name,
        date: event.date,
        location: event.location,
        description: event.description,
        userId: event.userId,
        isPublished: true,
      );

      await LocalDatabase.saveEvent(updatedEvent);
      await FirestoreService.saveEvent(updatedEvent);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event published successfully!')),
      );

      _refreshEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish event: $e')),
      );
    }
  }

  void _deleteEvent(BuildContext context, Event event) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        // Delete from local database
        await LocalDatabase.deleteEvent(event.id);

        // Delete from Firestore
        await FirestoreService.deleteEvent(event.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully!')),
        );

        _refreshEvents();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (ctx) => AddEventScreen(),
            ),
          )
              .then((result) {
            if (result == true) {
              _refreshEvents();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
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
              final event = events[index];
              return ListTile(
                title: Text(event.name),
                subtitle: Text(event.location),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => EventGiftsScreen(
                        eventId: event.id,
                        eventName: event.name,
                      ),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Publish button
                    if (!event.isPublished)
                      IconButton(
                        icon: const Icon(Icons.cloud_upload),
                        onPressed: () => _publishEvent(context, event),
                      ),

                    // Edit button
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (ctx) => AddEventScreen(
                              existingEvent: event,
                            ),
                          ),
                        )
                            .then((result) {
                          if (result == true) {
                            _refreshEvents();
                          }
                        });
                      },
                    ),

                    // Delete button
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteEvent(context, event),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
