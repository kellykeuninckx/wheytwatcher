import 'package:shared_preferences/shared_preferences.dart';

import '../data/database.dart';

/// Poort van `BadgeTiers.swift` (BadgeTier/BadgeTiers/BadgeMetrics): drie
/// prestatie-categorieën (kwark, streak, wandelen), elk met vaste drempels.
class BadgeTier {
  const BadgeTier({required this.threshold, required this.name, required this.message});

  final double threshold;
  final String name;
  final String message;
}

class BadgeTiers {
  BadgeTiers._();

  static const List<BadgeTier> kwark = [
    BadgeTier(threshold: 1000, name: 'Eerste hap', message: 'Dat was je eerste kilo. Je kwarkreis begint nu.'),
    BadgeTier(threshold: 2500, name: 'Kwark liefhebber', message: '2,5kg kwark is ongeveer 4 basketballen. Probeer die eens tegelijk in je handen te houden ;-)'),
    BadgeTier(threshold: 5000, name: 'Kwark beginneling', message: "5kg kwark – dat zijn zo'n 25 vinyl platen van je favoriete artiest."),
    BadgeTier(threshold: 10000, name: 'Kwark doorzetter', message: "10kg kwark – inmiddels heb je een kleine peuter op. Nou ja, 't gewicht ervan dan."),
    BadgeTier(threshold: 15000, name: 'Kwark kenner', message: '15kg kwark... Til eens een kettlebel van dat gewicht op, dan weet je pas hoeveel het is.'),
    BadgeTier(threshold: 30000, name: 'Kwark fanaat', message: '30kg kwark is het gewicht van meer dan 11.000 pingpongballetjes. Ga zo door.'),
    BadgeTier(threshold: 60000, name: 'Kwark kampioen', message: '60kg kwark. Dat zijn meer dan 19.000 theezakjes. Dat is één kopje per dag, 52 jaar lang!'),
    BadgeTier(threshold: 100000, name: 'Kwark koning', message: '100kg kwark. Je bent de onbetwiste kwark koning. Gefeliciteerd!'),
  ];

  static const List<BadgeTier> streak = [
    BadgeTier(threshold: 7, name: '7 dagen streak', message: '7 dagen op rij gelogd. Dat is een mooie gewoonte in wording.'),
    BadgeTier(threshold: 14, name: '14 dagen streak', message: '14 dagen al! Dat is duidelijk geen toeval meer.'),
    BadgeTier(threshold: 30, name: '30 dagen streak', message: '30 dagen… Een hele maand gelogd. Dat noem je nou discipline.'),
    BadgeTier(threshold: 50, name: '50 dagen streak', message: "50 dagen op rij – dat is halverwege de 100. Zet 'm op!"),
    BadgeTier(threshold: 75, name: '75 dagen streak', message: '75 dagen. Bijna bijna de 100, nu niet stoppen!'),
    BadgeTier(threshold: 100, name: '100 dagen streak', message: '100 dagen op rij gelogd. Dat mag gevierd worden!'),
  ];

  static const List<BadgeTier> walking = [
    BadgeTier(threshold: 10, name: 'Wandelaar', message: '10 uur gewandeld. Dat is een mooi begin.'),
    BadgeTier(threshold: 15, name: 'Vlotte wandelaar', message: '15 uur gewandeld. Dat is ongeveer van Amsterdam naar Rotterdam.'),
    BadgeTier(threshold: 30, name: 'Wandelheld', message: '30 uur gewandeld. Dat is ongeveer van Amsterdam naar Antwerpen.'),
    BadgeTier(threshold: 50, name: 'Wandelfanaat', message: '50 uur gewandeld. Dat is ongeveer als van Groningen naar Maastricht lopen — bijna het hele land door.'),
    BadgeTier(threshold: 75, name: 'Wandellegende', message: '75 uur gewandeld. Dat is ongeveer als van Amsterdam naar Parijs lopen.'),
    BadgeTier(threshold: 100, name: 'Wandelkoning', message: '100 uur gewandeld. Wauw, dat is serieus indrukwekkend.'),
  ];

  /// Hoogste behaalde tier (of null).
  static BadgeTier? current(double value, List<BadgeTier> tiers) {
    BadgeTier? result;
    for (final tier in tiers) {
      if (value >= tier.threshold) result = tier;
    }
    return result;
  }

  /// Eerstvolgende nog niet behaalde tier (of null).
  static BadgeTier? next(double value, List<BadgeTier> tiers) {
    for (final tier in tiers) {
      if (value < tier.threshold) return tier;
    }
    return null;
  }
}

/// Ruwe waardes waarop de tiers gebaseerd zijn — poort van `BadgeMetrics`.
class BadgeMetrics {
  BadgeMetrics._();

  static double totalKwarkGrams(List<FoodLogEntryRow> foodEntries) {
    return foodEntries
        .where((e) => e.name.toLowerCase().contains('kwark'))
        .fold<double>(0, (sum, e) => sum + e.grams);
  }

  static int longestLoggingStreak(List<FoodLogEntryRow> foodEntries, List<DayStatusRow> dayStatuses) {
    DateTime day0(DateTime d) => DateTime(d.year, d.month, d.day);
    final loggedDays = foodEntries.map((e) => day0(e.date)).toSet();
    final marked = dayStatuses.map((s) => day0(s.date)).toSet();

    if (loggedDays.isEmpty) return 0;
    var day = loggedDays.reduce((a, b) => a.isBefore(b) ? a : b);
    final today = day0(DateTime.now());

    var current = 0;
    var longest = 0;
    while (!day.isAfter(today)) {
      if (loggedDays.contains(day)) {
        current += 1;
        if (current > longest) longest = current;
      } else if (!marked.contains(day)) {
        current = 0;
      }
      day = day.add(const Duration(days: 1));
    }
    return longest;
  }

  static double totalWalkingHours(List<TrainingSessionRow> trainings) {
    final minutes = trainings
        .where((t) => t.type == TrainingType.walking)
        .fold<int>(0, (sum, t) => sum + t.durationMinutes);
    return minutes / 60.0;
  }
}

/// Detecteert nieuw ontgrendelde badges door het huidige tier per categorie te
/// vergelijken met het laatst-erkende tier (bewaard in [SharedPreferences]),
/// zodat de "nieuwe badge"-popup op Vandaag elke tier maar één keer toont.
/// Poort van `checkNewBadge()` uit TodayView.swift.
class BadgeTracker {
  BadgeTracker._();

  static const String _kwarkKey = 'wwLastAckKwarkTier';
  static const String _streakKey = 'wwLastAckStreakTier';
  static const String _walkingKey = 'wwLastAckWalkingTier';

  static Future<List<BadgeTier>> checkNewlyUnlocked(AppDatabase db) async {
    final food = await db.select(db.foodLogEntries).get();
    final trainings = await db.select(db.trainingSessions).get();
    final dayStatuses = await db.select(db.dayStatuses).get();
    final prefs = await SharedPreferences.getInstance();

    final newly = <BadgeTier>[];
    Future<void> check(String key, double value, List<BadgeTier> tiers) async {
      final current = BadgeTiers.current(value, tiers);
      if (current != null && prefs.getString(key) != current.name) {
        await prefs.setString(key, current.name);
        newly.add(current);
      }
    }

    await check(_kwarkKey, BadgeMetrics.totalKwarkGrams(food), BadgeTiers.kwark);
    await check(_streakKey, BadgeMetrics.longestLoggingStreak(food, dayStatuses).toDouble(), BadgeTiers.streak);
    await check(_walkingKey, BadgeMetrics.totalWalkingHours(trainings), BadgeTiers.walking);
    return newly;
  }
}
