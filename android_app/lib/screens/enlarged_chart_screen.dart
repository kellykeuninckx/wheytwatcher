import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Poort van `EnlargedChartSheet`: toont een grafiek uitvergroot (premium).
class EnlargedChartScreen extends StatelessWidget {
  const EnlargedChartScreen({super.key, required this.isDark, required this.title, required this.chart});

  final bool isDark;
  final String title;
  final Widget chart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WwColors.background(isDark),
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: WwColors.darkAccent(isDark))),
        backgroundColor: WwColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: WwColors.teal),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: WwCard(
            isDark: isDark,
            child: SizedBox(height: 360, child: chart),
          ),
        ),
      ),
    );
  }
}
