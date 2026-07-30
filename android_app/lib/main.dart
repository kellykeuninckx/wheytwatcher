import 'package:flutter/material.dart';

import 'data/database.dart';
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
      home: _ProfileSeeder(
        db: widget.db,
        builder: (context) => TodayScreen(
          db: widget.db,
          isDark: _isDark,
          onToggleTheme: () => setState(() => _isDark = !_isDark),
        ),
      ),
    );
  }
}

/// Zorgt dat er altijd één [UserProfileRow] bestaat om tegen te rekenen.
///
/// Er is nog geen onboarding-flow geport (aparte vervolgstap) — tot die er
/// is, zaait dit een placeholder-profiel zodat het Vandaag-scherm meteen
/// data heeft.
class _ProfileSeeder extends StatefulWidget {
  const _ProfileSeeder({required this.db, required this.builder});

  final AppDatabase db;
  final WidgetBuilder builder;

  @override
  State<_ProfileSeeder> createState() => _ProfileSeederState();
}

class _ProfileSeederState extends State<_ProfileSeeder> {
  late final Future<void> _ready = _ensureProfile();

  Future<void> _ensureProfile() async {
    final existing = await widget.db.select(widget.db.userProfiles).getSingleOrNull();
    if (existing != null) return;

    await widget.db.into(widget.db.userProfiles).insert(
          UserProfilesCompanion.insert(
            name: 'Jij',
            age: 30,
            sex: Sex.male,
            heightCm: 175,
            currentWeightKg: 75,
            goalMode: GoalMode.maintenance,
            goalPace: GoalPace.normal,
            activityLevel: ActivityLevel.moderate,
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: WwColors.background(true),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        return widget.builder(context);
      },
    );
  }
}
