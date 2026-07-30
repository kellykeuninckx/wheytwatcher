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
