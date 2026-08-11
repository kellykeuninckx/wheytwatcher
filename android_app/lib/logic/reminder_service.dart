import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/database.dart';

/// Poort van `ReminderManager.swift`: drie lokale meldingen, elk apart aan/uit
/// (max. 1 per dag, geen spam):
///   1. 's Avonds nog niet gelogd (vandaag 18:00)
///   2. Wekelijkse gewicht-herinnering (gekozen wegdag 09:00, rouleren tekst)
///   3. Doelperiode loopt bijna af (3 dagen voor het einde, 10:00)
///
/// Instellingen leven in [SharedPreferences] (waar iOS `@AppStorage` gebruikt),
/// met dezelfde sleutels/standaardwaarden zodat het Profielscherm ze kan tonen.
class ReminderService {
  ReminderService._();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const String _channelId = 'ww_reminders';
  static const String _channelName = 'Herinneringen';
  static const String _channelDescription = 'Log-, weeg- en doelherinneringen';

  static const int _eveningId = 1;
  static const int _weeklyId = 2;
  static const int _goalId = 3;

  // Prefs-sleutels (gelijk aan iOS' @AppStorage-namen).
  static const String kEveningEnabled = 'wwReminderEveningLog';
  static const String kWeeklyEnabled = 'wwReminderWeeklyWeighIn';
  static const String kGoalEnabled = 'wwReminderGoalEnding';
  static const String kWeighInWeekday = 'wwWeighInWeekday';
  static const String _variantKey = 'wwWeighInVariantIndex';

  /// Wegdag volgt iOS' Calendar-conventie: 1 = zondag … 7 = zaterdag. Default 2 (maandag).
  static const int _defaultWeekday = 2;

  static const List<String> _weighInVariants = [
    'Een wekelijkse meting geeft het beste beeld van je trend.',
    'Elke week hetzelfde moment kiezen maakt het makkelijker om het vol te houden.',
    'Je gewicht schommelt dagelijks — de wekelijkse trend vertelt het echte verhaal.',
  ];

  // MARK: - Init & toestemming

  /// Eenmalig bij app-start: tijdzones laden en de plugin initialiseren.
  static Future<void> init() async {
    tz_data.initializeTimeZones();
    // NL/BE-gebruikers; Europe/Amsterdam dekt de juiste lokale tijd inclusief zomertijd.
    tz.setLocalLocation(tz.getLocation('Europe/Amsterdam'));
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  /// Vraagt (indien nodig) toestemming voor meldingen op Android 13+.
  static Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      );

  static Future<void> _schedule(int id, String title, String body, tz.TZDateTime when) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  // MARK: - Prefs-toegang

  static Future<bool> eveningEnabled() async => (await SharedPreferences.getInstance()).getBool(kEveningEnabled) ?? true;
  static Future<bool> weeklyEnabled() async => (await SharedPreferences.getInstance()).getBool(kWeeklyEnabled) ?? true;
  static Future<bool> goalEnabled() async => (await SharedPreferences.getInstance()).getBool(kGoalEnabled) ?? true;
  static Future<int> weighInWeekday() async => (await SharedPreferences.getInstance()).getInt(kWeighInWeekday) ?? _defaultWeekday;

  // MARK: - 1. 's Avonds nog niet gelogd

  static Future<void> refreshEveningLogReminder({required bool hasLoggedToday}) async {
    await _plugin.cancel(_eveningId);
    if (!await eveningEnabled() || hasLoggedToday) return;

    final now = tz.TZDateTime.now(tz.local);
    final scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 18);
    if (!scheduled.isAfter(now)) return; // 18:00 al voorbij vandaag

    await _schedule(
      _eveningId,
      'Vandaag nog niet gelogd.',
      'Vergeet niet je dag in te voeren of een rustdag in te stellen.',
      scheduled,
    );
  }

  static Future<void> setEveningLogReminderEnabled(bool enabled) async {
    (await SharedPreferences.getInstance()).setBool(kEveningEnabled, enabled);
    if (!enabled) await _plugin.cancel(_eveningId);
  }

  // MARK: - 2. Wekelijkse gewicht-herinnering

  /// Aan-/uitzetten of wegdag wijzigen: plant meteen een verse melding met de
  /// eerstvolgende tekst-variant (of haalt 'm weg).
  static Future<void> setWeeklyWeighInReminder({required bool enabled, required int weekday}) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(kWeeklyEnabled, enabled);
    prefs.setInt(kWeighInWeekday, weekday);

    await _plugin.cancel(_weeklyId);
    if (!enabled) return;
    await _scheduleNextWeighIn(weekday);
  }

  /// Bij app-open: plan de volgende weegherinnering alleen als er nog geen
  /// staat (zodat de tekst-variant niet bij elke start doorrouleert).
  static Future<void> refreshWeeklyWeighInReminderIfNeeded() async {
    if (!await weeklyEnabled()) {
      await _plugin.cancel(_weeklyId);
      return;
    }
    final pending = await _plugin.pendingNotificationRequests();
    if (pending.any((r) => r.id == _weeklyId)) return;
    await _scheduleNextWeighIn(await weighInWeekday());
  }

  static Future<void> _scheduleNextWeighIn(int iosWeekday) async {
    final prefs = await SharedPreferences.getInstance();
    final variantIndex = (prefs.getInt(_variantKey) ?? 0) % _weighInVariants.length;
    prefs.setInt(_variantKey, (variantIndex + 1) % _weighInVariants.length);

    // iOS-weekday (1=zo…7=za) -> Dart-weekday (1=ma…7=zo).
    final dartWeekday = ((iosWeekday + 5) % 7) + 1;
    final when = _nextWeekdayAt(dartWeekday, 9);

    await _schedule(_weeklyId, 'Tijd om te wegen.', _weighInVariants[variantIndex], when);
  }

  static tz.TZDateTime _nextWeekdayAt(int dartWeekday, int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var candidate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    while (candidate.weekday != dartWeekday || !candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
      candidate = tz.TZDateTime(tz.local, candidate.year, candidate.month, candidate.day, hour);
    }
    return candidate;
  }

  // MARK: - 3. Doelperiode loopt bijna af

  static Future<void> setGoalEndingReminderEnabled(bool enabled) async {
    (await SharedPreferences.getInstance()).setBool(kGoalEnabled, enabled);
    if (!enabled) await _plugin.cancel(_goalId);
  }

  static Future<void> _refreshGoalEndingReminder(DateTime? endDate) async {
    await _plugin.cancel(_goalId);
    if (!await goalEnabled() || endDate == null) return;

    final reminderDate = endDate.subtract(const Duration(days: 3));
    final scheduled = tz.TZDateTime(tz.local, reminderDate.year, reminderDate.month, reminderDate.day, 10);
    if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) return;

    await _schedule(
      _goalId,
      'Je doelperiode loopt bijna af.',
      'Nog 3 dagen te gaan. Nog even volhouden!',
      scheduled,
    );
  }

  // MARK: - Alles verversen (bij app-open)

  /// Leest de huidige stand uit de database en (her)plant de drie meldingen.
  static Future<void> refreshAll(AppDatabase db) async {
    final now = DateTime.now();
    bool isToday(DateTime d) => d.year == now.year && d.month == now.month && d.day == now.day;

    final allLogs = await db.select(db.foodLogEntries).get();
    await refreshEveningLogReminder(hasLoggedToday: allLogs.any((e) => isToday(e.date)));

    await refreshWeeklyWeighInReminderIfNeeded();

    final activePeriods = (await db.select(db.goalPeriods).get()).where((p) => p.isActive).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    DateTime? endDate;
    if (activePeriods.isNotEmpty) {
      final p = activePeriods.first;
      endDate = p.startDate.add(Duration(days: p.durationWeeks * 7));
    }
    await _refreshGoalEndingReminder(endDate);
  }
}
