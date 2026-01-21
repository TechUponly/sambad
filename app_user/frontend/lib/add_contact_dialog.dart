import 'package:flutter/material.dart';
import 'models/contact.dart';

class AddContactDialog extends StatefulWidget {
  final void Function(Contact) onAdd;
  const AddContactDialog({super.key, required this.onAdd});

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF23272F), Color(0xFF18181B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Color(0xFF00FFC2).withOpacity(0.18), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Contact', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Montserrat')),
            const SizedBox(height: 18),
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Color(0xFF00FFC2))),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Phone', labelStyle: TextStyle(color: Color(0xFF00FFC2))),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter phone' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(foregroundColor: Colors.white70, textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onAdd(Contact(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _nameController.text.trim(), phone: _phoneController.text.trim()));
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFC2),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    elevation: 6,
                    shadowColor: const Color(0xFF00FFC2).withOpacity(0.18),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
