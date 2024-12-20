import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/services/firestore_services.dart';
import 'package:hedieaty/style/app_colors.dart';
import 'package:hedieaty/widgets/my_custom_app_bar.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';
import '../services/db_helper.dart';

class AddEventScreen extends StatefulWidget {
  final Event? existingEvent;

  const AddEventScreen({Key? key, this.existingEvent}) : super(key: key);

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _location;
  late String _description;
  late DateTime _date;
  final loggedInUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
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
    final picked = await showDatePicker(
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
    await LocalDatabase.saveEvent(event);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(widget.existingEvent == null
              ? 'Draft saved!'
              : 'Draft updated!')),
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
    await LocalDatabase.saveEvent(event);
    await FirestoreService.saveEvent(event);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event published successfully!')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MyCustomAppBar(title: "Add Event"),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                            'Event Name', _name, (value) => _name = value!),
                        SizedBox(
                          height: 20,
                        ),
                        _buildTextField('Location', _location,
                            (value) => _location = value ?? ''),
                        SizedBox(
                          height: 20,
                        ),
                        _buildTextField('Description', _description,
                            (value) => _description = value ?? '',
                            maxLines: 3),
                        SizedBox(
                          height: 20,
                        ),
                        _buildDateSelector(),
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String placeholder, String initialValue, Function(String?) onSave,
      {int maxLines = 1}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: placeholder,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: maxLines,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter $placeholder.' : null,
      onSaved: onSave,
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.secondary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Date: ${_date.toLocal()}'.split(' ')[0],
                style: TextStyle(color: AppColors.secondary)),
            const Icon(Icons.calendar_today, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 400,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            onPressed: _saveDraft,
            child: Text(
                widget.existingEvent == null ? 'Save Draft' : 'Update Draft'),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        SizedBox(
          width: 400,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            onPressed: _publishEvent,
            child: Text(
                widget.existingEvent == null ? 'Publish' : 'Publish Update'),
          ),
        ),
      ],
    );
  }
}
