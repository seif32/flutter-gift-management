import 'package:flutter/material.dart';
import 'package:hedieaty/services/firestore_services.dart';
import 'package:hedieaty/style/app_colors.dart';
import 'package:hedieaty/widgets/my_custom_app_bar.dart';
import '../models/gift.dart';
import '../services/db_helper.dart';
import 'package:uuid/uuid.dart';

class AddGiftScreen extends StatefulWidget {
  final String eventId;
  final Gift? gift;

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

  final List<String> _statuses = ['Available', 'Reserved', 'Purchased'];

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
        await LocalDatabase.saveGift(gift);
        await FirestoreService.saveGift(gift);
      } else {
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
      backgroundColor: AppColors.background,
      appBar: MyCustomAppBar(title: "Add Gift"),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                        'Gift Name', _name, (value) => _name = value!),
                    _buildTextField('Description', _description,
                        (value) => _description = value!,
                        maxLines: 3),
                    _buildTextField(
                        'Category', _category, (value) => _category = value!),
                    _buildTextField(
                      'Price',
                      _price.toString(),
                      (value) => _price = double.parse(value!),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildStatusDropdown(),
                    const SizedBox(height: 24),
                    _buildActionButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String initialValue, Function(String?) onSave,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label.' : null,
        onSaved: onSave,
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _status,
      items: _statuses.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) => setState(() => _status = value!),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: 400,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          backgroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _submit,
        child: Text(
          widget.gift == null ? 'Save Gift' : 'Update Gift',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
