import '../data/database.dart';

class MacroTarget {
  const MacroTarget({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.fiberGrams,
    required this.bmr,
    required this.estimatedMaintenanceCalories,
    required this.trainingCalories,
  });

  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double fiberGrams;
  final double bmr;
  final double estimatedMaintenanceCalories;
  final double trainingCalories;
}

extension GoalPaceAdjustment on GoalPace {
  double calorieAdjustmentPercentage(GoalMode mode) {
    switch (mode) {
      case GoalMode.cut:
        switch (this) {
          case GoalPace.conservative:
            return -0.10;
          case GoalPace.normal:
            return -0.15;
          case GoalPace.aggressive:
            return -0.20;
        }
      case GoalMode.maintenance:
        return 0.0;
      case GoalMode.bulk:
        switch (this) {
          case GoalPace.conservative:
            return 0.05;
          case GoalPace.normal:
            return 0.10;
          case GoalPace.aggressive:
            return 0.15;
        }
    }
  }
}

extension ActivityLevelMultiplier on ActivityLevel {
  double get multiplier {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.20;
      case ActivityLevel.light:
        return 1.35;
      case ActivityLevel.moderate:
        return 1.45;
      case ActivityLevel.active:
        return 1.60;
    }
  }
}

class MacroCalculator {
  MacroCalculator._();

  static MacroTarget calculate({
    required UserProfileRow profile,
    required GoalMode goalMode,
    required GoalPace goalPace,
    double extraTrainingCalories = 0,
    double manualCalorieAdjustment = 0,
  }) {
    final double bmr;
    switch (profile.sex) {
      case Sex.male:
        bmr = 10 * profile.currentWeightKg + 6.25 * profile.heightCm - 5 * profile.age + 5;
      case Sex.female:
        bmr = 10 * profile.currentWeightKg + 6.25 * profile.heightCm - 5 * profile.age - 161;
    }

    final maintenance = bmr * profile.activityLevel.multiplier;
    final adjustment = maintenance * goalPace.calorieAdjustmentPercentage(goalMode);
    final targetCalories = maintenance + adjustment + extraTrainingCalories + manualCalorieAdjustment;

    final double proteinMultiplier;
    final double fatMultiplier;
    switch (goalMode) {
      case GoalMode.cut:
        proteinMultiplier = 2.2;
        fatMultiplier = 0.7;
      case GoalMode.maintenance:
        proteinMultiplier = 2.0;
        fatMultiplier = 0.8;
      case GoalMode.bulk:
        proteinMultiplier = 1.8;
        fatMultiplier = 0.8;
    }

    final protein = profile.currentWeightKg * proteinMultiplier;
    final fat = profile.currentWeightKg * fatMultiplier;
    const fiber = 30.0;

    final caloriesFromProtein = protein * 4;
    final caloriesFromFat = fat * 9;
    final remainingCalories = (targetCalories - caloriesFromProtein - caloriesFromFat).clamp(0, double.infinity);
    final carbs = remainingCalories / 4;

    return MacroTarget(
      calories: targetCalories,
      proteinGrams: protein,
      carbsGrams: carbs,
      fatGrams: fat,
      fiberGrams: fiber,
      bmr: bmr,
      estimatedMaintenanceCalories: maintenance,
      trainingCalories: extraTrainingCalories,
    );
  }
}

/// Poort van `GoalDurationAdvisor` — geadviseerde duur per doel/tempo, met onderbouwing.
class GoalDurationAdvisor {
  GoalDurationAdvisor._();

  static int recommendedWeeks(GoalMode mode, GoalPace pace) {
    switch (mode) {
      case GoalMode.maintenance:
        return 12;
      case GoalMode.cut:
        switch (pace) {
          case GoalPace.conservative:
            return 12;
          case GoalPace.normal:
            return 8;
          case GoalPace.aggressive:
            return 6;
        }
      case GoalMode.bulk:
        switch (pace) {
          case GoalPace.conservative:
            return 16;
          case GoalPace.normal:
            return 12;
          case GoalPace.aggressive:
            return 8;
        }
    }
  }

  static String adviceText(GoalMode mode, GoalPace pace) {
    switch (mode) {
      case GoalMode.maintenance:
        return 'Bij onderhoud houden we standaard 12 weken aan. Zo verzamelt de app genoeg data om je trend te tonen, en evalueren we daarna of je wil bijsturen.';
      case GoalMode.cut:
        switch (pace) {
          case GoalPace.conservative:
            return 'Een voorzichtige cut duurt meestal 10–12 weken. Het kleinere calorietekort beschermt je spiermassa beter, maar vraagt meer geduld.';
          case GoalPace.normal:
            return 'Een normale cut duurt meestal 8 weken — voor de meeste mensen een goede balans tussen tempo en het behouden van spiermassa.';
          case GoalPace.aggressive:
            return 'Een agressieve cut duurt meestal 6 weken. Door het grotere tekort gaat het sneller, maar we raden af dit langer vol te houden: het risico op spierverlies en terugval neemt toe.';
        }
      case GoalMode.bulk:
        switch (pace) {
          case GoalPace.conservative:
            return 'Een voorzichtige bulk duurt meestal 14–16 weken. Langzaam aankomen beperkt vetopslag, maar kost meer tijd.';
          case GoalPace.normal:
            return 'Een normale bulk duurt meestal 10–12 weken — een gangbare balans tussen spiergroei en vetopslag.';
          case GoalPace.aggressive:
            return 'Een agressieve bulk duurt meestal 8 weken. Je komt sneller aan, maar met meer kans op overtollig vet — hou dit kort en evalueer daarna opnieuw.';
        }
    }
  }

  /// Puur informatief: gegeven een doelgewicht en gekozen duur, wat voor tempo impliceert dat?
  static String? impliedPaceDescription({
    required double currentWeightKg,
    required double targetWeightKg,
    required int durationWeeks,
  }) {
    if (durationWeeks <= 0 || currentWeightKg <= 0) return null;

    final totalChange = (targetWeightKg - currentWeightKg).abs();
    if (totalChange <= 0.1) return null;

    final weeklyRateKg = totalChange / durationWeeks;
    final weeklyRatePercent = (weeklyRateKg / currentWeightKg) * 100;

    final String paceLabel;
    if (weeklyRatePercent < 0.4) {
      paceLabel = 'een voorzichtig tempo';
    } else if (weeklyRatePercent < 0.75) {
      paceLabel = 'een gemiddeld tempo';
    } else {
      paceLabel = 'een agressief tempo';
    }

    final roundedRate = (weeklyRateKg * 10).round() / 10;
    final verb = targetWeightKg < currentWeightKg ? 'afvallen' : 'aankomen';

    return 'Dat komt neer op ongeveer $roundedRate kg per week $verb — dat valt onder $paceLabel.';
  }
}

class TrainingCalculator {
  TrainingCalculator._();

  static const Map<TrainingType, (double, double)> _metRanges = {
    TrainingType.heavyStrength: (4.5, 7.0),
    TrainingType.hypertrophy: (4.0, 6.5),
    TrainingType.hyrox: (7.0, 11.0),
    TrainingType.gymnastics: (3.5, 6.0),
    TrainingType.running: (7.0, 12.0),
    TrainingType.walking: (2.5, 4.0),
    TrainingType.boxing: (6.0, 10.0),
    TrainingType.swimming: (6.0, 10.0),
    TrainingType.crossfit: (7.0, 12.0),
    TrainingType.cycling: (4.0, 10.0),
    TrainingType.yoga: (2.5, 4.0),
    TrainingType.racketSports: (5.0, 8.0),
    TrainingType.rowing: (5.0, 9.0),
    TrainingType.other: (3.0, 8.0),
  };

  static double estimateCalories({
    required TrainingType type,
    required int durationMinutes,
    required int rpe,
    required double bodyWeightKg,
  }) {
    final clampedRpe = rpe.clamp(1, 10);
    final (lower, upper) = _metRanges[type]!;

    final position = (clampedRpe - 1) / 9.0;
    final met = lower + ((upper - lower) * position);

    return met * 3.5 * bodyWeightKg / 200.0 * durationMinutes;
  }
}
