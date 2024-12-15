// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/services/firestore_services.dart';
import '../models/gift.dart';
import '../services/db_helper.dart';
import 'package:uuid/uuid.dart';

class AddGiftScreen extends StatefulWidget {
  final String eventId; // Pass the event ID when navigating to this screen

  const AddGiftScreen({required this.eventId, Key? key}) : super(key: key);

  @override
  _AddGiftScreenState createState() => _AddGiftScreenState();
}

class _AddGiftScreenState extends State<AddGiftScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = Uuid();
  String _name = '';
  String _description = '';
  String _category = '';
  double _price = 0.0;
  String _status = 'Pending';
  // final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final gift = Gift(
      id: _uuid.v4(),
      name: _name,
      description: _description,
      category: _category,
      price: _price,
      status: _status,
      eventId: widget.eventId,
    );
    try {
      // Save to Local Database
      await LocalDatabase.saveGift(gift);

      // Sync data to Firestore
      await FirestoreService.saveGift(gift);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift added successfully!')),
      );
    } catch (e) {
      // Handle errors with detailed messages
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving gift: $e")),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Gift')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Gift Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name.';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Category'),
                onSaved: (value) => _category = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _price = double.parse(value!),
              ),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Gift'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
