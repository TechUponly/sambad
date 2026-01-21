import 'package:flutter/material.dart';

class GrowthRateTile extends StatelessWidget {
  final String label;
  final String value;
  const GrowthRateTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black54, blurRadius: 2)])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white, shadows: [Shadow(color: Colors.black54, blurRadius: 2)])),
        ],
      ),
    );
  }
}