import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Poort van `WWPlaceholderCard.swift`.
class PlaceholderCard extends StatelessWidget {
  const PlaceholderCard({
    super.key,
    required this.isDark,
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  final bool isDark;
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return WwCard(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(icon, size: 56, color: color),
            const SizedBox(height: 20),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: WwColors.darkAccent(isDark))),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: WwColors.secondaryText(isDark)),
            ),
          ],
        ),
      ),
    );
  }
}
