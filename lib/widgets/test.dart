// import 'package:hedieaty/screens/add_friend_screen.dart';
// import 'package:hedieaty/services/firestore_services.dart';

// @override
// void initState() {
//   super.initState();
//   _loadFriends();
// }

// void _loadFriends() {
//   setState(() {
//     _giftsFuture = FirestoreService.getFriendsWithDetails(userId);
//   });
// }





//  showModalBottomSheet(
//                               context: context,
//                               builder: (context) => AddFriendScreen(
//                                 userId: user.id,
//                                 height: 200,
//                               ) .then((_) => _loadFriends()),
//                               shape: const RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.vertical(
//                                   top: Radius.circular(25.0),
//                                 ),
//                               ),
//                               isScrollControlled: true,
//                             );
