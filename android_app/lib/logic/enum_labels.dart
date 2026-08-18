import 'package:flutter/material.dart';

import '../data/database.dart';

/// Dutch display labels, mirroring the Swift enum rawValues.
extension TrainingTypeLabel on TrainingType {
  String get label {
    switch (this) {
      case TrainingType.heavyStrength:
        return 'Kracht zwaar';
      case TrainingType.hypertrophy:
        return 'Kracht hypertrofie';
      case TrainingType.hyrox:
        return 'Hyrox / conditioning';
      case TrainingType.gymnastics:
        return 'Gymnastics / skill';
      case TrainingType.running:
        return 'Hardlopen';
      case TrainingType.walking:
        return 'Wandelen';
      case TrainingType.boxing:
        return 'Boksen';
      case TrainingType.swimming:
        return 'Zwemmen';
      case TrainingType.crossfit:
        return 'CrossFit';
      case TrainingType.cycling:
        return 'Fietsen';
      case TrainingType.yoga:
        return 'Yoga / Pilates';
      case TrainingType.racketSports:
        return 'Tennis / Padel';
      case TrainingType.rowing:
        return 'Roeien';
      case TrainingType.other:
        return 'Overig';
    }
  }

  IconData get icon {
    switch (this) {
      case TrainingType.heavyStrength:
      case TrainingType.hypertrophy:
        return Icons.fitness_center;
      case TrainingType.hyrox:
      case TrainingType.crossfit:
        return Icons.bolt;
      case TrainingType.gymnastics:
        return Icons.sports_gymnastics;
      case TrainingType.running:
        return Icons.directions_run;
      case TrainingType.walking:
        return Icons.directions_walk;
      case TrainingType.boxing:
        return Icons.sports_mma;
      case TrainingType.swimming:
        return Icons.pool;
      case TrainingType.cycling:
        return Icons.directions_bike;
      case TrainingType.yoga:
        return Icons.self_improvement;
      case TrainingType.racketSports:
        return Icons.sports_tennis;
      case TrainingType.rowing:
        return Icons.rowing;
      case TrainingType.other:
        return Icons.sports;
    }
  }
}

extension GoalModeLabel on GoalMode {
  String get label {
    switch (this) {
      case GoalMode.cut:
        return 'Cut';
      case GoalMode.maintenance:
        return 'Onderhoud';
      case GoalMode.bulk:
        return 'Bulk';
    }
  }

  String get shortDescription {
    switch (this) {
      case GoalMode.cut:
        return 'Vetpercentage omlaag, gains beschermen';
      case GoalMode.maintenance:
        return 'Op gewicht blijven, spiermassa behouden';
      case GoalMode.bulk:
        return 'Aankomen, spiermassa opbouwen';
    }
  }
}

extension SexLabel on Sex {
  String get label {
    switch (this) {
      case Sex.male:
        return 'Man';
      case Sex.female:
        return 'Vrouw';
    }
  }
}

extension GoalPaceLabel on GoalPace {
  String get label {
    switch (this) {
      case GoalPace.conservative:
        return 'Voorzichtig';
      case GoalPace.normal:
        return 'Normaal';
      case GoalPace.aggressive:
        return 'Agressief';
    }
  }
}

extension MealCategoryLabel on MealCategory {
  String get label {
    switch (this) {
      case MealCategory.breakfast:
        return 'Ontbijt';
      case MealCategory.lunch:
        return 'Lunch';
      case MealCategory.dinner:
        return 'Avondeten';
      case MealCategory.snack:
        return 'Snack';
      case MealCategory.preWorkout:
        return 'Pre-workout';
      case MealCategory.postWorkout:
        return 'Post-workout';
      case MealCategory.other:
        return 'Overig';
    }
  }
}

extension ActivityLevelLabel on ActivityLevel {
  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Zittend';
      case ActivityLevel.light:
        return 'Licht actief';
      case ActivityLevel.moderate:
        return 'Redelijk actief';
      case ActivityLevel.active:
        return 'Actief';
    }
  }
}

extension BodyMeasurementTypeLabel on BodyMeasurementType {
  String get label {
    switch (this) {
      case BodyMeasurementType.waist:
        return 'Taille';
      case BodyMeasurementType.chest:
        return 'Borst';
      case BodyMeasurementType.hips:
        return 'Heupen';
      case BodyMeasurementType.arm:
        return 'Arm';
      case BodyMeasurementType.thigh:
        return 'Dij';
    }
  }
}

extension DayStatusTypeLabel on DayStatusType {
  String get label {
    switch (this) {
      case DayStatusType.sick:
        return 'Ziek';
      case DayStatusType.vacation:
        return 'Vakantie';
      case DayStatusType.restDay:
        return 'Rustdag';
    }
  }

  IconData get icon {
    switch (this) {
      case DayStatusType.sick:
        return Icons.medical_services;
      case DayStatusType.vacation:
        return Icons.flight;
      case DayStatusType.restDay:
        return Icons.bedtime;
    }
  }
}
