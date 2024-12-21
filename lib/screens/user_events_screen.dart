import 'package:flutter/material.dart';
import 'package:hedieaty/screens/add_event_screen.dart';
import 'package:hedieaty/screens/event_gifts_screen.dart';
import 'package:hedieaty/services/firestore_services.dart';
import 'package:hedieaty/style/app_colors.dart';
import 'package:hedieaty/widgets/my_custom_app_bar.dart';
import '../models/event.dart';
import '../services/db_helper.dart';
import 'package:intl/intl.dart';

class UserEventsScreen extends StatefulWidget {
  final String userId;

  const UserEventsScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _UserEventsScreenState createState() => _UserEventsScreenState();
}

class _UserEventsScreenState extends State<UserEventsScreen> {
  late Future<List<Event>> _eventsFuture;
  // ignore: unused_field
  String _sortCriteria = 'name'; // Default sorting criteria
  Color _nameButtonColor = AppColors.secondary; // Default color for name
  Color _dateButtonColor = Colors.grey; // Default color for date

  @override
  void initState() {
    super.initState();
    _refreshEvents();
  }

  void _refreshEvents() {
    setState(() {
      _eventsFuture = LocalDatabase.getUserEvents(widget.userId);
    });
  }

  void _sortEvents(String criteria) {
    setState(() {
      _sortCriteria = criteria;
      if (criteria == 'name') {
        _nameButtonColor = AppColors.primary;
        _dateButtonColor = Colors.grey;
      } else if (criteria == 'date') {
        _dateButtonColor = AppColors.primary;
        _nameButtonColor = Colors.grey;
      }
      _eventsFuture = _eventsFuture.then((events) {
        if (criteria == 'name') {
          events.sort((a, b) => a.name.compareTo(b.name));
        } else if (criteria == 'date') {
          events.sort((a, b) => a.date.compareTo(b.date));
        }
        return events;
      });
    });
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    return Card(
      color: AppColors.primaryLight,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => EventGiftsScreen(
                eventId: event.id,
                eventName: event.name,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Date Container
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('dd').format(event.date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('MMM').format(event.date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Event Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!event.isPublished)
                    IconButton(
                      icon: Icon(Icons.cloud_upload, color: AppColors.primary),
                      onPressed: () => _publishEvent(context, event),
                    ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: AppColors.primary),
                    onSelected: (String value) {
                      if (value == 'edit') {
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (ctx) =>
                                AddEventScreen(existingEvent: event),
                          ),
                        )
                            .then((result) {
                          if (result == true) {
                            _refreshEvents();
                          }
                        });
                      } else if (value == 'delete') {
                        _deleteEvent(context, event);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _publishEvent(BuildContext context, Event event) async {
    try {
      final updatedEvent = Event(
        id: event.id,
        name: event.name,
        date: event.date,
        location: event.location,
        description: event.description,
        userId: event.userId,
        isPublished: true,
      );

      await LocalDatabase.saveEvent(updatedEvent);
      await FirestoreService.saveEvent(updatedEvent);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Event published successfully!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _refreshEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to publish event: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _deleteEvent(BuildContext context, Event event) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: AppColors.secondary)),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await LocalDatabase.deleteEvent(event.id);
        await FirestoreService.deleteEvent(event.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        _refreshEvents();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete event: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyCustomAppBar(title: "My Events"),
      body: Column(
        children: [
          // Buttons for sorting
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _sortEvents('name'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _nameButtonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Sort by Name'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _sortEvents('date'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: _dateButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Sort by Date'),
                ),
              ],
            ),
          ),
          // Events List
          Expanded(
            child: FutureBuilder<List<Event>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No events found.'));
                } else {
                  final events = snapshot.data!;
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(context, events[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (ctx) => AddEventScreen(),
                ),
              )
              .then((_) => _refreshEvents());
        },
        child: Icon(Icons.card_giftcard),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
