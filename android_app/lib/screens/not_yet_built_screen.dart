import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Placeholder voor tabbladen die nog niet geport zijn (Maaltijden,
/// Favorieten, Logboek — zie MainTabView.swift).
class NotYetBuiltScreen extends StatelessWidget {
  const NotYetBuiltScreen({super.key, required this.isDark, required this.title, required this.icon});

  final bool isDark;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 56, color: WwColors.teal),
                const SizedBox(height: 16),
                Text(
                  '$title volgt nog',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: WwColors.darkAccent(isDark)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
