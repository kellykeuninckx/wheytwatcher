import 'package:flutter/material.dart';

import '../data/database.dart';
import '../theme/theme.dart';
import 'favorites_screen.dart';
import 'logbook_screen.dart';
import 'meals_screen.dart';
import 'progress_screen.dart';
import 'today_screen.dart';

/// Poort van `MainTabView.swift`.
class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key, required this.db, required this.isDark, required this.onToggleTheme});

  final AppDatabase db;
  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final screens = [
      TodayScreen(db: widget.db, isDark: isDark, onToggleTheme: widget.onToggleTheme),
      MealsScreen(db: widget.db, isDark: isDark),
      FavoritesScreen(db: widget.db, isDark: isDark, onAdded: () => setState(() => _index = 0)),
      LogbookScreen(db: widget.db, isDark: isDark),
      ProgressScreen(db: widget.db, isDark: isDark),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: WwColors.cardBackground(isDark),
        selectedItemColor: WwColors.teal,
        unselectedItemColor: WwColors.secondaryText(isDark),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Vandaag'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Maaltijden'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorieten'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Logboek'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progressie'),
        ],
      ),
    );
  }
}
