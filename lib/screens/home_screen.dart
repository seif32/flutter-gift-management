import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hedieaty/authentication/auth.dart';
import 'package:hedieaty/models/app_user.dart';
import 'package:hedieaty/screens/add_event_screen.dart';
import 'package:hedieaty/screens/add_friend_screen.dart';
import 'package:hedieaty/screens/friends_list_screen.dart';
import 'package:hedieaty/screens/my_pledged_gifts_screeen.dart';
import 'package:hedieaty/screens/user_events_screen.dart';
import 'package:hedieaty/style/app_colors.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  final AppUser user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hello, ${toBeginningOfSentenceCase(user.name)}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
            icon: const Icon(
              Icons.login_outlined,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Let's make someone's day special.",
              style: TextStyle(
                  fontSize: 17, color: Color.fromARGB(255, 68, 66, 66)),
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.grey, width: 0.2), // Thin black border
                ),
                child: SvgPicture.asset(
                  'assets/images/home.svg',
                  height: 140,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 210, // Set your desired height
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Friends",
                          style: TextStyle(fontSize: 20),
                        ),
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => AddFriendScreen(
                                userId: user.id,
                                height: 200,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25.0),
                                ),
                              ),
                              isScrollControlled: true,
                            );
                          },
                          icon: const Icon(Icons.person_add),
                        )
                      ],
                    ),
                  ),
                  Expanded(child: FriendsListScreen(userId: user.id))
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            const Divider(
              color: Colors.grey, // Set the color of the line
              thickness: 0.75, // Set the thickness of the line
              indent: 16, // Set the left padding
              endIndent: 16, // Set the right padding
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Events",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text("icon")
                    ],
                  ),
                  Text("tiles")
                ],
              ),
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
              child: const Text('View My Pledged Gifts'),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => AddEventScreen(),
            ),
          );
        },
        child: const Icon(Icons.card_giftcard),
      ),
    );
  }
}
