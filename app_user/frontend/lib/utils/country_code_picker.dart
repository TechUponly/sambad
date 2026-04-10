import 'package:flutter/material.dart';
import 'country_codes.dart';
import '../theme/app_colors.dart';

/// A searchable country code picker dialog.
/// Returns the selected [CountryCode] or null if dismissed.
Future<CountryCode?> showCountryCodePicker(BuildContext context) {
  return showDialog<CountryCode>(
    context: context,
    builder: (ctx) => const _CountryCodePickerDialog(),
  );
}

class _CountryCodePickerDialog extends StatefulWidget {
  const _CountryCodePickerDialog();

  @override
  State<_CountryCodePickerDialog> createState() => _CountryCodePickerDialogState();
}

class _CountryCodePickerDialogState extends State<_CountryCodePickerDialog> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dc = AppColors.of(context);
    final results = CountryCodes.search(_query);

    return Dialog(
      backgroundColor: dc.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Expanded(child: Text('Select Country', style: TextStyle(color: dc.text, fontSize: 18, fontWeight: FontWeight.bold))),
                  IconButton(icon: Icon(Icons.close, color: dc.textMuted, size: 22), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 12),
              // Search bar
              TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: TextStyle(color: dc.text),
                decoration: InputDecoration(
                  hintText: 'Search country or code...',
                  hintStyle: TextStyle(color: dc.textHint),
                  prefixIcon: Icon(Icons.search, color: dc.textHint, size: 20),
                  filled: true,
                  fillColor: dc.text.withValues(alpha: 0.08),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 8),
              // Country list
              Expanded(
                child: results.isEmpty
                    ? Center(child: Text('No countries found', style: TextStyle(color: dc.textMuted)))
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (_, i) {
                          final cc = results[i];
                          return ListTile(
                            dense: true,
                            leading: Text(cc.flag, style: const TextStyle(fontSize: 24)),
                            title: Text(cc.name, style: TextStyle(color: dc.text, fontSize: 14)),
                            trailing: Text(cc.code, style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
                            onTap: () => Navigator.of(context).pop(cc),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
