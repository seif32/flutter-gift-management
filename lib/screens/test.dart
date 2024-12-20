import 'package:flutter/material.dart';
import 'package:hedieaty/screens/friend_events_list_screen.dart';
import 'package:hedieaty/services/firestore_services.dart';

class FriendsListScreen extends StatelessWidget {
  final String userId;

  const FriendsListScreen({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FirestoreService.getFriendsWithDetails(userId),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('You have no friends, please add them'));
        }
        final friends = snapshot.data!;

        return ListView.builder(
          scrollDirection:
              Axis.horizontal, // Set the scroll direction to horizontal
          itemCount: friends.length,
          itemBuilder: (ctx, index) {
            final friend = friends[index];
            final friendId = friend['id'];
            final friendName = friend['name'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Card(
                elevation: 8,
                color: Colors.white,
                child: Container(
                  width: 200, // Set the width of each card
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: friend['profilePicture'] != null
                            ? NetworkImage(friend['profilePicture'])
                            : null,
                        child: friend['profilePicture'] == null
                            ? const Icon(Icons.person)
                            : null,
                        radius: 40, // Adjust the size of the avatar
                      ),
                      const SizedBox(height: 10),
                      Text(
                        friendName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        friend['eventCount'] == 0
                            ? 'No Upcoming Events'
                            : 'Upcoming Events: ${friend['eventCount']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: friend['eventCount'] == 0
                              ? Colors.grey
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Icon(Icons.arrow_forward_ios_outlined),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
