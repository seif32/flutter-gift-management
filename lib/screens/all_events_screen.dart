// import 'package:flutter/material.dart';
// import 'package:hedieaty/services/firestore_services.dart';
// import '../models/event.dart';
// import '../models/gift.dart';

// class AllEventsScreen extends StatelessWidget {
//   const AllEventsScreen({super.key});

//   Future<Map<Event, List<Gift>>> _fetchAllEventsAndGifts() async {
//     final events = await FirestoreService.getAllEvents();
//     final eventGiftsMap = <Event, List<Gift>>{};

//     for (final event in events) {
//       final gifts = await FirestoreService.getGiftsForEvent(event.id);
//       eventGiftsMap[event] = gifts;
//     }

//     return eventGiftsMap;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('All Events')),
//       body: FutureBuilder<Map<Event, List<Gift>>>(
//         future: _fetchAllEventsAndGifts(),
//         builder: (ctx, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No events found.'));
//           }
//           final eventGiftsMap = snapshot.data!;
//           return ListView(
//             children: eventGiftsMap.entries.map((entry) {
//               final event = entry.key;
//               final gifts = entry.value;
//               return ExpansionTile(
//                 title: Text(event.name),
//                 subtitle: Text('${event.date.toLocal()} - ${event.location}'),
//                 children: gifts.map((gift) {
//                   return ListTile(
//                     title: Text(gift.name),
//                     subtitle: Text(
//                       'Category: ${gift.category}, Price: \$${gift.price}',
//                     ),
//                     trailing: Text(
//                       gift.status,
//                       style: TextStyle(
//                         color: gift.status == 'Completed'
//                             ? Colors.green
//                             : Colors.red,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }
