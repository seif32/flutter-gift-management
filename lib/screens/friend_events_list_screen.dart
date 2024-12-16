import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../services/db_helper.dart';

class FriendEventsListScreen extends StatelessWidget {
  final String friendId;
  final String friendName;

  const FriendEventsListScreen({
    required this.friendId,
    required this.friendName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$friendName's Gift List")),
      body: FutureBuilder<List<Gift>>(
        future: LocalDatabase.getGiftsByUser(friendId),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No gifts found.'));
          }
          final gifts = snapshot.data!;
          return ListView.builder(
            itemCount: gifts.length,
            itemBuilder: (ctx, index) {
              final gift = gifts[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(gift.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Description: ${gift.description}"),
                      Text("Category: ${gift.category}"),
                      Text("Price: \$${gift.price.toStringAsFixed(2)}"),
                      Text("Status: ${gift.status}"),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: gift.status == "Available"
                        ? () => _pledgeGift(context, gift)
                        : null,
                    child: const Text('Pledge'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _pledgeGift(BuildContext context, Gift gift) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pledge Gift'),
        content: Text('Are you sure you want to pledge "${gift.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      await LocalDatabase.updateGiftStatus(gift.id, 'Pledged');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have pledged "${gift.name}".')),
      );
    }
  }
}
