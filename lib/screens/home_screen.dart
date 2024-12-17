import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/authentication/auth.dart';
import 'package:hedieaty/models/app_user.dart';
import 'package:hedieaty/screens/add_event_screen.dart';
import 'package:hedieaty/screens/add_friend_screen.dart';
import 'package:hedieaty/screens/friends_list_screen.dart';
import 'package:hedieaty/screens/my_pledged_gifts_screeen.dart';
import 'package:hedieaty/screens/user_events_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppUser user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user.name}!'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEventScreen()),
                );
              },
              child: const Text('Add Event'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserEventsScreen(userId: user.id),
                  ),
                );
              },
              child: const Text('View My Events'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => AllEventsScreen()),
            //     );
            //   },
            //   child: const Text('View All Events'),
            // ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddFriendScreen(),
                  ),
                );
              },
              child: const Text('Add Friend'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FriendsListScreen(userId: user.id),
                  ),
                );
              },
              child: const Text('View Friend'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPledgedGiftsPage(userId: user.id),
                  ),
                );
              },
              child: const Text('View My pledged Gifts'),
            ),
          ],
        ),
      ),
    );
  }
}
