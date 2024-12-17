import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/services/firestore_services.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  final String userId;

  const MyPledgedGiftsPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<MyPledgedGiftsPage> createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  List<Map<String, dynamic>> pledgedGifts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPledgedGifts();
  }

  Future<void> fetchPledgedGifts() async {
    setState(() {
      isLoading = true;
      print('Loading started...');
    });

    try {
      final loggedInUserId =
          FirebaseAuth.instance.currentUser!.uid; // Get logged-in user ID
      print(
          'Calling FirestoreService.getPledgedGiftsByUser with loggedInUserId: $loggedInUserId');
      final gifts =
          await FirestoreService.getPledgedGiftsByUser(loggedInUserId);

      print(
          '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Fetched gifts from Firestore: $gifts');

      setState(() {
        pledgedGifts = gifts;
        print(
            '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@pledgedGifts list updated: $pledgedGifts');
      });

      if (gifts.isEmpty) {
        print(
            '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@No pledged gifts found for loggedInUserId: $loggedInUserId');
      }
    } catch (e) {
      print(
          '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Error occurred while fetching pledged gifts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load pledged gifts.')),
      );
    } finally {
      setState(() {
        isLoading = false;
        print('Loading finished.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pledgedGifts.isEmpty
              ? const Center(child: Text('No pledged gifts found.'))
              : ListView.builder(
                  itemCount: pledgedGifts.length,
                  itemBuilder: (context, index) {
                    final gift = pledgedGifts[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.card_giftcard,
                            color: Colors.deepPurple),
                        title: Text(
                          gift['name'] ?? 'Gift Name',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Due Date: ${gift['dueDate'] ?? 'N/A'}'),
                            Text('Friend: ${gift['friendName']}'),
                            Text('Email: ${gift['friendEmail']}'),
                            Text('Phone: ${gift['friendPhone']}'),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 18, color: Colors.grey),
                      ),
                    );
                  },
                ),
    );
  }
}
