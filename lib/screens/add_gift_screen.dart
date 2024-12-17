// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/services/firestore_services.dart';
import '../models/gift.dart';
import '../services/db_helper.dart';
import 'package:uuid/uuid.dart';

class AddGiftScreen extends StatefulWidget {
  final String eventId;
  final Gift? gift; // Pass gift for editing

  const AddGiftScreen({required this.eventId, this.gift, Key? key})
      : super(key: key);

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
  String _status = 'Available';

  @override
  void initState() {
    super.initState();
    if (widget.gift != null) {
      _name = widget.gift!.name;
      _description = widget.gift!.description;
      _category = widget.gift!.category;
      _price = widget.gift!.price;
      _status = widget.gift!.status;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final gift = Gift(
      id: widget.gift?.id ?? _uuid.v4(),
      name: _name,
      description: _description,
      category: _category,
      price: _price,
      status: _status,
      eventId: widget.eventId,
    );

    try {
      if (widget.gift == null) {
        // New Gift
        await LocalDatabase.saveGift(gift);
        await FirestoreService.saveGift(gift);
      } else {
        // Update Existing Gift
        await LocalDatabase.updateGift(gift);
        await FirestoreService.saveGift(gift);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift saved successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving gift: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gift == null ? 'Add Gift' : 'Edit Gift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Gift Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a name.' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                onSaved: (value) => _category = value!,
              ),
              TextFormField(
                initialValue: _price.toString(),
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _price = double.parse(value!),
              ),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Gift'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
