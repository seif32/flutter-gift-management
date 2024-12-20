import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift.dart';
import 'package:hedieaty/services/db_helper.dart';
import 'package:hedieaty/services/firestore_services.dart';
import 'package:hedieaty/style/app_colors.dart';
import 'package:hedieaty/widgets/my_custom_app_bar.dart';
import 'add_gift_screen.dart';

class EventGiftsScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const EventGiftsScreen({
    required this.eventId,
    required this.eventName,
    Key? key,
  }) : super(key: key);

  @override
  State<EventGiftsScreen> createState() => _EventGiftsScreenState();
}

class _EventGiftsScreenState extends State<EventGiftsScreen> {
  late Future<List<Gift>> _giftsFuture;
  String _sortCriteria = 'name'; // Default sorting criteria

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  void _loadGifts() {
    setState(() {
      _giftsFuture = LocalDatabase.getGiftsForEvent(widget.eventId);
    });
  }

  void _sortGifts(String criteria) {
    setState(() {
      _sortCriteria = criteria;
      _giftsFuture = _giftsFuture.then((gifts) {
        if (criteria == 'name') {
          gifts.sort((a, b) => a.name.compareTo(b.name));
        } else if (criteria == 'price') {
          gifts.sort((a, b) => a.price.compareTo(b.price));
        } else if (criteria == 'status') {
          gifts.sort((a, b) => a.status.compareTo(b.status));
        }
        return gifts;
      });
    });
  }

  void _deleteGift(String giftId) async {
    try {
      await LocalDatabase.deleteGift(giftId);
      await FirestoreService.deleteGift(widget.eventId, giftId);
      _loadGifts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift deleted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete gift: $e')),
      );
    }
  }

  void _editGift(Gift gift) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (ctx) =>
                AddGiftScreen(eventId: widget.eventId, gift: gift),
          ),
        )
        .then((_) => _loadGifts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(title: 'Gifts for ${widget.eventName}'),
      body: Column(
        children: [
          // Sorting Buttons inside a Scrollable Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 35),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () => _sortGifts('name'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _sortCriteria == 'name'
                          ? AppColors.secondary
                          : Colors.grey,
                    ),
                    child: const Text(
                      'Sort by Name',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _sortGifts('price'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _sortCriteria == 'price'
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                    child: const Text(
                      'Sort by Price',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _sortGifts('status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _sortCriteria == 'status'
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                    child: const Text(
                      'Sort by Status',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Gift>>(
              future: _giftsFuture,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No gifts found for this event.'),
                  );
                }
                final gifts = snapshot.data!;
                return ListView.builder(
                  itemCount: gifts.length,
                  itemBuilder: (ctx, index) {
                    final gift = gifts[index];
                    final isPledged = gift.status == 'Pledged';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: AppColors.background,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            gift.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Category: ${gift.category}\nPrice: \$${gift.price.toStringAsFixed(2)}\nStatus: ${gift.status}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          trailing: isPledged
                              ? Container(
                                  padding: const EdgeInsets.all(
                                      8.0), // Adjust the padding value as needed
                                  decoration: BoxDecoration(
                                    color: Colors.red, // Background color
                                    borderRadius: BorderRadius.circular(
                                        12), // Adjust the radius value as needed
                                  ),
                                  child: Text(
                                    "Pledged",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                )
                              : PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') _editGift(gift);
                                    if (value == 'delete') _deleteGift(gift.id);
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
