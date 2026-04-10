import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/contact.dart';
import 'utils/phone_validator.dart';
import 'utils/country_code_picker.dart';
import 'utils/country_codes.dart';
import 'theme/app_colors.dart';
import 'utils/responsive.dart';

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
  String? _phoneError;
  String _countryCode = '+91';

  Future<void> _add() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a contact name'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final phoneValidation = PhoneValidator.validate(_phoneCtrl.text, _countryCode);
    if (phoneValidation != null) {
      setState(() => _phoneError = phoneValidation);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(phoneValidation), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 3)),
      );
      return;
    }

    setState(() { _loading = true; _phoneError = null; });
    
    final cleanedPhone = PhoneValidator.cleanPhone(_phoneCtrl.text);
    final fullPhone = '$_countryCode$cleanedPhone';
    final contact = Contact(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      phone: fullPhone,
    );
    widget.onAdd(contact);
    if (!mounted) return;
    setState(() { _loading = false; _showSuccess = true; });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Stack(children: [
    Dialog(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 24))),
      child: Container(
        padding: Responsive.paddingAll(context, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Contact', style: TextStyle(color: c.text, fontSize: Responsive.fontSize(context, 26), fontWeight: FontWeight.bold)),
            SizedBox(height: Responsive.vertical(context, 28)),
            TextField(
              controller: _nameCtrl,
              enabled: !_loading,
              style: TextStyle(color: c.text),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Name',
                hintStyle: TextStyle(color: c.textMuted),
                filled: true,
                fillColor: c.text.withValues(alpha: 0.08),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 16)), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: Responsive.vertical(context, 18)),
            Row(
              children: [
                GestureDetector(
                  onTap: _loading ? null : () async {
                    final selected = await showCountryCodePicker(context);
                    if (selected != null) setState(() => _countryCode = selected.code);
                  },
                  child: Container(
                    padding: Responsive.paddingSymmetric(context, h: 12, v: 14),
                    decoration: BoxDecoration(
                      color: c.text.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(Responsive.radius(context, 16)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${CountryCodes.findByCode(_countryCode)?.flag ?? ''} $_countryCode', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: Responsive.fontSize(context, 14))),
                        Icon(Icons.arrow_drop_down, color: c.textMuted, size: Responsive.size(context, 18)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: Responsive.horizontal(context, 8)),
                Expanded(
                  child: TextField(
                    controller: _phoneCtrl,
                    enabled: !_loading,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: c.text),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(PhoneValidator.getExpectedDigits(_countryCode)),
                    ],
                    onChanged: (_) {
                      if (_phoneError != null) setState(() => _phoneError = null);
                    },
                    decoration: InputDecoration(
                      hintText: 'Phone (${PhoneValidator.getExpectedDigits(_countryCode)} digits)',
                      hintStyle: TextStyle(color: c.textMuted),
                      filled: true,
                      fillColor: c.text.withValues(alpha: 0.08),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 16)), borderSide: BorderSide.none),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 16)), borderSide: const BorderSide(color: Colors.red)),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 16)), borderSide: const BorderSide(color: Colors.red, width: 2)),
                      errorText: _phoneError,
                      errorStyle: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.vertical(context, 28)),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _loading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _loading ? null : _add,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.radius(context, 14))),
                    padding: Responsive.paddingSymmetric(context, h: 32, v: 16),
                  ),
                  child: _loading
                    ? SizedBox(width: Responsive.size(context, 20), height: Responsive.size(context, 20), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    if (_showSuccess) Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 400),
            tween: Tween<double>(begin: 0, end: 1),
            curve: Curves.elasticOut,
            builder: (context, double value, child) => Transform.scale(
              scale: value,
              child: Container(
                width: Responsive.size(context, 120), height: Responsive.size(context, 120),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF5B7FFF), Color(0xFF4A6FEE)]),
                  boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 5)],
                ),
                child: Center(
                  child: Container(
                    width: Responsive.size(context, 60), height: Responsive.size(context, 60),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12)],
                    ),
                    child: Icon(Icons.check, color: AppColors.success, size: Responsive.size(context, 42)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  ]);
  }

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }
}
