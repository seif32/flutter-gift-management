import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/services/firestore_services.dart';
import '../models/event.dart';
import '../services/db_helper.dart';
import 'package:uuid/uuid.dart';

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = Uuid();
  String _name = '';
  String _location = '';
  String _description = '';
  DateTime _date = DateTime.now();
  final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;

  void _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final event = Event(
      id: _uuid.v4(),
      name: _name,
      date: _date,
      location: _location,
      description: _description,
      userId: loggedInUserId,
    );

    await LocalDatabase.saveEvent(event); // Save draft locally

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event saved as draft!')),
    );
  }

  void _publishEvent() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final event = Event(
        id: _uuid.v4(),
        name: _name,
        date: _date,
        location: _location,
        description: _description,
        userId: loggedInUserId,
        isPublished: true);

    // Check if the event already exists locally
    final existingEvent = await LocalDatabase.getEventById(event.id);

    if (existingEvent == null) {
      // Save draft locally
      await LocalDatabase.saveEvent(event);
    }

    // Publish to cloud
    await FirestoreService.saveEvent(event);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event published successfully!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name.';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location'),
                onSaved: (value) => _location = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value!,
              ),
              ElevatedButton(
                onPressed: _saveDraft,
                child: const Text('Save Draft'),
              ),
              ElevatedButton(
                onPressed: _publishEvent,
                child: const Text('Publish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
