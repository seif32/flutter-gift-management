import 'package:flutter/material.dart';
import 'package:hedieaty/screens/friend_events_list_screen.dart';
import 'package:hedieaty/services/firestore_services.dart';
import 'package:hedieaty/style/app_colors.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: Card(
                elevation: 2,
                color: AppColors.primaryLight,
                child: InkWell(
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
                  child: Container(
                    width: 150, // Set the width of each card
                    height: 180, // Set the height of each card
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          backgroundImage: friend['profilePicture'] != null
                              ? NetworkImage(friend['profilePicture'])
                              : null,
                          child: friend['profilePicture'] == null
                              ? const Icon(Icons.person)
                              : null,
                          radius: 30, // Adjust the size of the avatar
                        ),
                        const SizedBox(height: 5),
                        Text(
                          friendName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          friend['eventCount'] == 0
                              ? 'No Events'
                              : '${friend['eventCount']} Events',
                          style: TextStyle(
                            fontSize: 15,
                            color: friend['eventCount'] == 0
                                ? Colors.grey
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
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
