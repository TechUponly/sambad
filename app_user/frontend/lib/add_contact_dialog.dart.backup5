import 'package:flutter/material.dart';
import 'models/contact.dart';

const Color kPrimaryBlue = Color(0xFF5B7FFF);
const Color kBgCard = Color(0xFF23272F);
const Color kSuccessGreen = Color(0xFF00C853);

class AddContactDialog extends StatefulWidget {
  final Function(Contact) onAdd;
  const AddContactDialog({super.key, required this.onAdd});
  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  bool _showSuccess = false;

  Future<void> _add() async {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(Duration(milliseconds: 500));
    final contact = Contact(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _nameCtrl.text, phone: _phoneCtrl.text);
    widget.onAdd(contact);
    if (!mounted) return;
    setState(() { _loading = false; _showSuccess = true; });
    await Future.delayed(Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Stack(children: [Dialog(backgroundColor: kBgCard, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), child: Container(padding: EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Add Contact', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)), SizedBox(height: 28), TextField(controller: _nameCtrl, enabled: !_loading, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Name', hintStyle: TextStyle(color: Colors.white54), filled: true, fillColor: Colors.white.withOpacity(0.08), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))), SizedBox(height: 18), TextField(controller: _phoneCtrl, enabled: !_loading, keyboardType: TextInputType.phone, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Phone', hintStyle: TextStyle(color: Colors.white54), filled: true, fillColor: Colors.white.withOpacity(0.08), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))), SizedBox(height: 28), Row(mainAxisAlignment: MainAxisAlignment.end, children: [TextButton(onPressed: _loading ? null : () => Navigator.pop(context), child: Text('Cancel')), SizedBox(width: 12), ElevatedButton(onPressed: _loading ? null : _add, style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)), child: _loading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Add', style: TextStyle(fontWeight: FontWeight.bold)))])]))), if (_showSuccess) Positioned.fill(child: Material(color: Colors.black54, child: Center(child: TweenAnimationBuilder(duration: Duration(milliseconds: 400), tween: Tween<double>(begin: 0, end: 1), curve: Curves.elasticOut, builder: (context, double value, child) => Transform.scale(scale: value, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF5B7FFF), Color(0xFF4A6FEE)]), boxShadow: [BoxShadow(color: kPrimaryBlue.withOpacity(0.5), blurRadius: 40, spreadRadius: 5)]), child: Center(child: Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12)]), child: Icon(Icons.check, color: kSuccessGreen, size: 42)))))))))]);

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }
}
