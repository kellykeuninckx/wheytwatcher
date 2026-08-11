import '../data/database.dart';

/// Poort van `AdaptiveCheckInResult` uit Calculators.swift.
sealed class AdaptiveCheckInResult {
  const AdaptiveCheckInResult();
}

/// Niet genoeg betrouwbare data om een advies op te baseren.
class InsufficientData extends AdaptiveCheckInResult {
  const InsufficientData(this.reason);
  final String reason;
}

/// Voortgang past bij het doel — geen aanpassing nodig.
class OnTrack extends AdaptiveCheckInResult {
  const OnTrack(this.message);
  final String message;
}

/// Voortgang blijft achter — voorstel om de calorieën met [kcal] bij te stellen.
class SuggestAdjustment extends AdaptiveCheckInResult {
  const SuggestAdjustment(this.kcal, this.reasoning);
  final double kcal;
  final String reasoning;
}

/// Achterstand door slechte adherence, niet door een verkeerd doel.
class SuggestAdherence extends AdaptiveCheckInResult {
  const SuggestAdherence(this.reasoning);
  final String reasoning;
}

enum _CalorieAdherence { aboveTarget, belowTarget, onTarget, unknown }

/// Poort van `AdaptiveCheckInEvaluator`: evalueert de laatste 14 dagen — genoeg
/// gelogd? en past de gewichtstrend bij het doel?
class AdaptiveCheckInEvaluator {
  AdaptiveCheckInEvaluator._();

  static DateTime _day0(DateTime d) => DateTime(d.year, d.month, d.day);

  static AdaptiveCheckInResult evaluate({
    required GoalPeriodRow period,
    required List<FoodLogEntryRow> foodEntries,
    required List<WeightLogRow> weightLogs,
    required List<TrainingSessionRow> trainings,
    required List<DayStatusRow> dayStatuses,
    required List<DailyTargetSnapshotRow> dailyTargetSnapshots,
  }) {
    final windowStart = _day0(DateTime.now().subtract(const Duration(days: 14)));

    final loggedDays = foodEntries.where((e) => !e.date.isBefore(windowStart)).map((e) => _day0(e.date)).toSet();
    final markedDaysSet = dayStatuses.where((s) => !s.date.isBefore(windowStart)).map((s) => _day0(s.date)).toSet();

    final trackableDays = (14 - markedDaysSet.length).clamp(1, 14);
    final loggingRate = loggedDays.length / trackableDays;

    final recentWeights = weightLogs
        .where((w) => !w.date.isBefore(windowStart) && !markedDaysSet.contains(_day0(w.date)))
        .toList();
    final trainingCount = trainings.where((t) => !t.date.isBefore(windowStart)).length;

    if (loggingRate < 0.7 || recentWeights.length < 3) {
      return const InsufficientData(
        'Je hebt de afgelopen 2 weken niet consistent genoeg gelogd (voeding en/of gewicht) om een betrouwbaar advies te geven. We wachten nog even met een aanpassing — hoe beter je logt, hoe scherper het advies.',
      );
    }

    final weeklyRate = _weeklyWeightChangeRate(recentWeights);
    if (weeklyRate == null) {
      return const InsufficientData(
        'We hebben nog niet genoeg gewichtsdata deze periode om een trend te bepalen. We wachten nog even met een aanpassing.',
      );
    }

    final adherence = _calorieAdherence(
      windowStart: windowStart,
      foodEntries: foodEntries,
      snapshots: dailyTargetSnapshots,
      markedDays: markedDaysSet,
    );

    switch (period.goalMode) {
      case GoalMode.cut:
        if (weeklyRate > -0.1) {
          if (adherence == _CalorieAdherence.aboveTarget) {
            return const SuggestAdherence(
              'Je data laat zien dat je de afgelopen 2 weken regelmatig boven je caloriebehoefte hebt gegeten. Probeer je hier zo goed mogelijk aan te houden, dan bereik je sneller je doel!',
            );
          }
          return SuggestAdjustment(
            -100,
            'Je hebt de afgelopen 2 weken consistent gelogd en ${trainingCount}x getraind, maar je gewicht daalt niet genoeg ten opzichte van je doel. Advies: verlaag je caloriebehoefte met 100 kcal per dag.',
          );
        }
        return const OnTrack('Je gewicht daalt zoals verwacht bij je cut. Ga zo door!');

      case GoalMode.bulk:
        if (weeklyRate < 0.1) {
          if (adherence == _CalorieAdherence.belowTarget) {
            return const SuggestAdherence(
              'Je data laat zien dat je de afgelopen 2 weken regelmatig onder je caloriebehoefte hebt gegeten. Probeer je hier zo goed mogelijk aan te houden, dan bereik je sneller je doel!',
            );
          }
          return SuggestAdjustment(
            100,
            'Je hebt de afgelopen 2 weken consistent gelogd en ${trainingCount}x getraind, maar je komt niet genoeg aan als we kijken naar je doel. Advies: verhoog je caloriebehoefte met 100 kcal per dag.',
          );
        }
        return const OnTrack('Je gewicht stijgt zoals verwacht bij je bulk. Ga zo door!');

      case GoalMode.maintenance:
        return const OnTrack('Je gewicht blijft stabiel — precies de bedoeling bij onderhoud.');
    }
  }

  static _CalorieAdherence _calorieAdherence({
    required DateTime windowStart,
    required List<FoodLogEntryRow> foodEntries,
    required List<DailyTargetSnapshotRow> snapshots,
    required Set<DateTime> markedDays,
  }) {
    final dailyCalories = <DateTime, double>{};
    for (final e in foodEntries.where((e) => !e.date.isBefore(windowStart))) {
      final day = _day0(e.date);
      dailyCalories[day] = (dailyCalories[day] ?? 0) + e.calories;
    }
    final dailyTargets = <DateTime, double>{};
    for (final s in snapshots.where((s) => !s.date.isBefore(windowStart))) {
      dailyTargets.putIfAbsent(_day0(s.date), () => s.calories);
    }

    final comparableDays = dailyCalories.keys.where((d) => !markedDays.contains(d)).toList();
    final diffs = <double>[];
    final targets = <double>[];
    for (final day in comparableDays) {
      final actual = dailyCalories[day];
      final target = dailyTargets[day];
      if (actual != null && target != null) {
        diffs.add(actual - target);
        targets.add(target);
      }
    }

    if (diffs.isEmpty || targets.isEmpty) return _CalorieAdherence.unknown;

    final averageDiff = diffs.reduce((a, b) => a + b) / diffs.length;
    final averageTarget = targets.reduce((a, b) => a + b) / targets.length;
    final threshold = (averageTarget * 0.05).clamp(50, double.infinity);

    if (averageDiff > threshold) return _CalorieAdherence.aboveTarget;
    if (averageDiff < -threshold) return _CalorieAdherence.belowTarget;
    return _CalorieAdherence.onTarget;
  }

  /// Kleinste-kwadraten regressie over een exponentieel voortschrijdend
  /// gemiddelde; geeft kg/week terug (of null bij te weinig data).
  static double? _weeklyWeightChangeRate(List<WeightLogRow> weights) {
    final sorted = List.of(weights)..sort((a, b) => a.date.compareTo(b.date));
    if (sorted.isEmpty) return null;

    final smoothed = <({DateTime date, double value})>[];
    var previous = sorted.first.weightKg;
    const alpha = 0.2;
    for (var i = 0; i < sorted.length; i++) {
      final value = i == 0 ? sorted[i].weightKg : alpha * sorted[i].weightKg + (1 - alpha) * previous;
      previous = value;
      smoothed.add((date: sorted[i].date, value: value));
    }

    if (smoothed.length < 2) return null;
    final referenceDate = smoothed.first.date;

    final xs = smoothed.map((p) => p.date.difference(referenceDate).inSeconds / 86400.0).toList();
    final ys = smoothed.map((p) => p.value).toList();

    final n = xs.length.toDouble();
    final sumX = xs.reduce((a, b) => a + b);
    final sumY = ys.reduce((a, b) => a + b);
    var sumXY = 0.0;
    var sumXX = 0.0;
    for (var i = 0; i < xs.length; i++) {
      sumXY += xs[i] * ys[i];
      sumXX += xs[i] * xs[i];
    }

    final denominator = n * sumXX - sumX * sumX;
    if (denominator == 0) return null;

    final slopePerDay = (n * sumXY - sumX * sumY) / denominator;
    return slopePerDay * 7;
  }
}
