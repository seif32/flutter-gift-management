import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hedieaty/models/app_user.dart';
import 'package:hedieaty/screens/add_friend_screen.dart';
import 'package:hedieaty/screens/friends_list_screen.dart';
import 'package:hedieaty/screens/my_pledged_gifts_screeen.dart';
import 'package:hedieaty/screens/profile_screen.dart';
import 'package:hedieaty/screens/user_events_screen.dart';
import 'package:hedieaty/services/firestore_services.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final AppUser user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _giftsFuture;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  void _loadFriends() {
    setState(() {
      _giftsFuture = FirestoreService.getFriendsWithDetails(widget.user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hello, ${toBeginningOfSentenceCase(widget.user.name)}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    user: widget.user,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.person),
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
                fontSize: 17,
                color: Color.fromARGB(255, 68, 66, 66),
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.2,
                  ), // Thin black border
                ),
                child: SvgPicture.asset(
                  'assets/images/home.svg',
                  height: 140,
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                                userId: widget.user.id,
                                height: 200,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25.0),
                                ),
                              ),
                              isScrollControlled: true,
                            ).then((_) => _loadFriends());
                          },
                          icon: const Icon(Icons.person_add),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: _giftsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text("Error loading friends."));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              "No friends found. \n Why not invite some to join you?",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        return FriendsListScreen(
                          userId: widget.user.id,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(
              color: Colors.grey,
              thickness: 0.75,
              indent: 16,
              endIndent: 16,
            ),
            const SizedBox(height: 20),
            _buildDiscoverMoreSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverMoreSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("Discover More", style: TextStyle(fontSize: 20)),
            Icon(Icons.more_horiz),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDiscoverCard(
              title: "My Events",
              subtitle: "Plan. Track. Celebrate!",
              imagePath: 'assets/images/home1.svg',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserEventsScreen(userId: widget.user.id),
                  ),
                );
              },
            ),
            _buildDiscoverCard(
              title: "My Pledged Gifts",
              subtitle: "Your Generosity, Organized",
              imagePath: 'assets/images/home2.svg',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MyPledgedGiftsPage(userId: widget.user.id),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiscoverCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        child: Container(
          padding: const EdgeInsets.all(10),
          height: 250,
          width: 170,
          child: Column(
            children: [
              SvgPicture.asset(imagePath, height: 120),
              const SizedBox(height: 10),
              const Divider(
                color: Colors.grey,
                thickness: 0.8,
                indent: 10,
                endIndent: 10,
              ),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color.fromARGB(255, 130, 130, 130),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
