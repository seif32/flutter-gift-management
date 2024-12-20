import 'package:flutter/material.dart';
import 'package:hedieaty/services/firestore_services.dart';
import 'package:hedieaty/widgets/my_custom_app_bar.dart';

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
    try {
      setState(() {
        isLoading = true;
      });

      final gifts = await FirestoreService.getPledgedGiftsByUser(
        widget.userId,
      );

      setState(() {
        pledgedGifts = gifts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load pledged gifts: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(
        title: "My Pledged Gifts",
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pledgedGifts.isEmpty
              ? const Center(
                  child: Text(
                  'You have no pledged gifts.',
                  style: TextStyle(fontSize: 16),
                ))
              : ListView.builder(
                  itemCount: pledgedGifts.length,
                  itemBuilder: (context, index) {
                    final gift = pledgedGifts[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gift Details
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  gift['name'] ?? 'Gift Name',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.deepPurple),
                                ),
                                Text(
                                  '\$${gift['price']?.toStringAsFixed(2) ?? 'N/A'}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Event Details
                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  const TextSpan(
                                      text: 'Event: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text:
                                          '${gift['eventName'] ?? 'Unknown Event'} '
                                      // '(${gift['eventDate'] != null ? DateFormat('MM/dd/yyyy').format(gift['eventDate']) : 'No Date'})',
                                      ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Friend Details
                            const Text(
                              'Friend Details:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text('Name: ${gift['friendName'] ?? 'N/A'}'),
                            Text('Email: ${gift['friendEmail'] ?? 'N/A'}'),
                            Text('Phone: ${gift['friendPhone'] ?? 'N/A'}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
