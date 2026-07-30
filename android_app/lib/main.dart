import 'package:flutter/material.dart';

import 'data/database.dart';
import 'screens/onboarding_screen.dart';
import 'screens/today_screen.dart';
import 'theme/theme.dart';

void main() {
  runApp(WheyMateApp(db: AppDatabase()));
}

class WheyMateApp extends StatefulWidget {
  const WheyMateApp({super.key, required this.db});

  final AppDatabase db;

  @override
  State<WheyMateApp> createState() => _WheyMateAppState();
}

class _WheyMateAppState extends State<WheyMateApp> {
  bool _isDark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whey, mate!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: RootScreen(
        db: widget.db,
        isDark: _isDark,
        onToggleTheme: () => setState(() => _isDark = !_isDark),
      ),
    );
  }
}

/// Poort van `RootView.swift`: geen profiel? Onboarding. Wel een profiel?
/// Vandaag-scherm. (MainTabView met de overige tabbladen volgt later.)
class RootScreen extends StatelessWidget {
  const RootScreen({super.key, required this.db, required this.isDark, required this.onToggleTheme});

  final AppDatabase db;
  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfileRow?>(
      stream: db.select(db.userProfiles).watchSingleOrNull(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: WwColors.background(isDark),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return OnboardingScreen(db: db, isDark: isDark);
        }

        return TodayScreen(db: db, isDark: isDark, onToggleTheme: onToggleTheme);
      },
    );
  }
}
