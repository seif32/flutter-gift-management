import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/services/firestore_services.dart';
import '../models/event.dart';
import '../services/db_helper.dart';
import 'package:uuid/uuid.dart';

class AddEventScreen extends StatefulWidget {
  final Event? existingEvent;

  const AddEventScreen({Key? key, this.existingEvent}) : super(key: key);

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  // final _uuid = Uuid();

  late String _name;
  late String _location;
  late String _description;
  late DateTime _date;

  final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    // Initialize fields with existing event data if editing
    if (widget.existingEvent != null) {
      _name = widget.existingEvent!.name;
      _location = widget.existingEvent!.location;
      _description = widget.existingEvent!.description;
      _date = widget.existingEvent!.date;
    } else {
      _name = '';
      _location = '';
      _description = '';
      _date = DateTime.now();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final event = Event(
      id: widget.existingEvent?.id ?? const Uuid().v4(),
      name: _name,
      date: _date,
      location: _location,
      description: _description,
      userId: loggedInUserId,
      isPublished: widget.existingEvent?.isPublished ?? false,
    );

    await LocalDatabase.saveEvent(event); // Save draft locally

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.existingEvent == null
            ? 'Event saved as draft!'
            : 'Event updated successfully!'),
      ),
    );

    Navigator.of(context).pop(true);
  }

  void _publishEvent() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final event = Event(
      id: widget.existingEvent?.id ?? const Uuid().v4(),
      name: _name,
      date: _date,
      location: _location,
      description: _description,
      userId: loggedInUserId,
      isPublished: true,
    );

    // Save event locally
    await LocalDatabase.saveEvent(event);

    // Publish to cloud
    await FirestoreService.saveEvent(event);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event published successfully!')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingEvent == null ? 'Add Event' : 'Edit Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
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
                initialValue: _location,
                decoration: const InputDecoration(labelText: 'Location'),
                onSaved: (value) => _location = value ?? '',
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Date: ${_date.toLocal()}'.split(' ')[0]),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _saveDraft,
                    child: Text(widget.existingEvent == null
                        ? 'Save Draft'
                        : 'Update Draft'),
                  ),
                  ElevatedButton(
                    onPressed: _publishEvent,
                    child: Text(widget.existingEvent == null
                        ? 'Publish'
                        : 'Publish Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
