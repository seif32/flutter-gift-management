import 'package:flutter/material.dart';
import 'package:hedieaty/screens/friend_gifts_list_screen.dart';
import '../models/event.dart';
import '../services/db_helper.dart';

class FriendEventsListScreen extends StatelessWidget {
  final String friendId;
  final String friendName;

  const FriendEventsListScreen({
    required this.friendId,
    required this.friendName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$friendName's Events")),
      body: FutureBuilder<List<Event>>(
        future: LocalDatabase.getEventsByUser(
            friendId), // Fetch events for the friend
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
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(event.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date: ${event.date}"),
                      Text("Location: ${event.location}"),
                      Text("Description: ${event.description}"),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendGiftsListScreen(
                            eventId: event.id, // Pass the event ID
                            eventName: event.name, // Pass the event name
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
