import 'package:flutter/material.dart';

class SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color? textColor;

  const SidebarButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.textColor,
  }) : super(key: key);

// ...existing code...
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.98),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.13),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: (textColor ?? Colors.black).withOpacity(0.08),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: textColor ?? (isDark ? Colors.white : Colors.black), size: 26),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: textColor ?? (isDark ? Colors.white : Colors.black),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
