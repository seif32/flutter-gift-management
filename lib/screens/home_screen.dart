import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hedieaty/models/app_user.dart';
import 'package:hedieaty/screens/add_friend_screen.dart';
import 'package:hedieaty/screens/friends_list_screen.dart';
import 'package:hedieaty/screens/my_pledged_gifts_screeen.dart';
import 'package:hedieaty/screens/profile_screen.dart';
import 'package:hedieaty/screens/user_events_screen.dart';
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
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                            user: user,
                          )),
                );
              },
              icon: Icon(Icons.man))
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
              height: 180, // Set your desired height
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
                        "Discover More",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text("icon")
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserEventsScreen(userId: user.id),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            // color: Colors.red,
                            height: 250,
                            width: 170,
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/home1.svg',
                                  height: 120,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                const Divider(
                                  color:
                                      Colors.grey, // Set the color of the line
                                  thickness:
                                      0.8, // Set the thickness of the line
                                  indent: 10, // Set the left padding
                                  endIndent: 10, // Set the right padding
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "My Events",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Text(
                                  "Plan. Track. Celebrate!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          Color.fromARGB(255, 130, 130, 130)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MyPledgedGiftsPage(userId: user.id),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            // color: Colors.red,
                            height: 250,
                            width: 170,
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/home2.svg',
                                  height: 120,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                const Divider(
                                  color:
                                      Colors.grey, // Set the color of the line
                                  thickness:
                                      0.8, // Set the thickness of the line
                                  indent: 10, // Set the left padding
                                  endIndent: 10, // Set the right padding
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  "My Pledged Gifts",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Text(
                                  "Your Generosity, Organized",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          Color.fromARGB(255, 130, 130, 130)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            // ElevatedButton(
            //   onPressed:
            //   child: const Text('View My Pledged Gifts'),
            // ),
            // ElevatedButton(
            //   onPressed:
            //   child: const Text('View My Events'),
            // ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: AppColors.primary,
      //   foregroundColor: Colors.white,
      //   onPressed: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //         builder: (ctx) => AddEventScreen(),
      //       ),
      //     );
      //   },
      //   child: const Icon(Icons.card_giftcard),
      // ),
    );
  }
}
