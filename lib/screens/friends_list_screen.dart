import 'package:flutter/material.dart';
import 'package:hedieaty/screens/friend_events_list_screen.dart';
import 'package:hedieaty/services/firestore_services.dart';

class FriendsListScreen extends StatelessWidget {
  final String userId;

  const FriendsListScreen({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Friends')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: FirestoreService.getFriendsWithDetails(userId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No friends found.'));
          }
          final friends = snapshot.data!;

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (ctx, index) {
              final friend = friends[index];
              final friendId = friend['id'];
              final friendName = friend['name'];

              return ListTile(
                title: Text(friendName),
                subtitle: Text(friend['email']),
                leading: CircleAvatar(
                  backgroundImage: friend['profilePicture'] != null
                      ? NetworkImage(friend['profilePicture'])
                      : null,
                  child: friend['profilePicture'] == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                trailing: Text(
                  friend['eventCount'] == 0
                      ? 'No Upcoming Events'
                      : 'Upcoming Events: ${friend['eventCount']}',
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => FriendEventsListScreen(
                        friendId: friendId,
                        friendName: friendName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
