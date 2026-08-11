import 'package:drift/drift.dart' show Value;

import '../data/database.dart';

/// Poort van de goalperiode-logica uit `Models.swift` (UserProfile + GoalPeriod):
/// afgeleide waarden en het starten van een nieuwe doelperiode.
extension GoalPeriodCalc on GoalPeriodRow {
  /// Einddatum = startdatum (begin van de dag) + duur in weken.
  DateTime get endDate {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    return start.add(Duration(days: durationWeeks * 7));
  }

  /// 1-based weeknummer waarin de gebruiker nu zit, geclampt tussen 1 en [durationWeeks].
  int get currentWeekNumber {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = today.difference(start).inDays;
    return (days ~/ 7 + 1).clamp(1, durationWeeks);
  }

  int get weeksRemaining => (durationWeeks - currentWeekNumber).clamp(0, durationWeeks);

  bool get hasEnded {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !today.isBefore(endDate);
  }
}

/// Helpers rond de doelperiodes van een profiel.
class GoalPeriodRepo {
  GoalPeriodRepo._();

  /// De actieve doelperiode (indien aanwezig).
  static Future<GoalPeriodRow?> active(AppDatabase db) async {
    final periods = await db.select(db.goalPeriods).get();
    final actives = periods.where((p) => p.isActive).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return actives.isEmpty ? null : actives.first;
  }

  /// Afgeronde/gewisselde doelperiodes, nieuwste eerst — voor de geschiedenis.
  static Future<List<GoalPeriodRow>> past(AppDatabase db) async {
    final periods = await db.select(db.goalPeriods).get();
    return periods.where((p) => !p.isActive).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  /// Rondt de actieve periode af (indien aanwezig) en start een nieuwe, en werkt
  /// het profiel-doel bij. Poort van `UserProfile.startNewGoalPeriod`.
  static Future<void> startNew(
    AppDatabase db,
    UserProfileRow profile, {
    required GoalMode mode,
    required GoalPace pace,
    required int durationWeeks,
  }) async {
    await db.transaction(() async {
      await (db.update(db.goalPeriods)..where((g) => g.isActive.equals(true))).write(
        GoalPeriodsCompanion(isActive: const Value(false), completedAt: Value(DateTime.now())),
      );

      await (db.update(db.userProfiles)..where((p) => p.id.equals(profile.id))).write(
        UserProfilesCompanion(goalMode: Value(mode), goalPace: Value(pace)),
      );

      await db.into(db.goalPeriods).insert(
            GoalPeriodsCompanion.insert(
              profileId: Value(profile.id),
              startDate: DateTime.now(),
              durationWeeks: durationWeeks,
              goalMode: mode,
              goalPace: pace,
            ),
          );
    });
  }
}
