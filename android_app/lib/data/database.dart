import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

enum Sex { male, female }

enum GoalMode { cut, maintenance, bulk }

enum GoalPace { conservative, normal, aggressive }

enum ActivityLevel { sedentary, light, moderate, active }

enum TrainingType {
  heavyStrength,
  hypertrophy,
  hyrox,
  gymnastics,
  running,
  walking,
  boxing,
  swimming,
  crossfit,
  cycling,
  yoga,
  racketSports,
  rowing,
  other,
}

enum MealCategory {
  breakfast,
  lunch,
  dinner,
  snack,
  preWorkout,
  postWorkout,
  other,
}

enum BodyMeasurementType { waist, chest, hips, arm, thigh }

enum DayStatusType { sick, vacation, restDay }

@DataClassName('UserProfileRow')
class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get age => integer()();
  TextColumn get sex => textEnum<Sex>()();
  RealColumn get heightCm => real()();
  RealColumn get currentWeightKg => real()();
  RealColumn get targetWeightKg => real().nullable()();
  RealColumn get estimatedBodyFatPercentage => real().nullable()();
  TextColumn get goalMode => textEnum<GoalMode>()();
  TextColumn get goalPace => textEnum<GoalPace>()();
  TextColumn get activityLevel => textEnum<ActivityLevel>()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('GoalPeriodRow')
class GoalPeriods extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get profileId =>
      integer().nullable().references(UserProfiles, #id)();
  DateTimeColumn get startDate => dateTime()();
  IntColumn get durationWeeks => integer()();
  TextColumn get goalMode => textEnum<GoalMode>()();
  TextColumn get goalPace => textEnum<GoalPace>()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  RealColumn get calorieAdjustment => real().withDefault(const Constant(0))();
  DateTimeColumn get lastCheckInDate => dateTime().nullable()();
}

@DataClassName('FoodProductRow')
class FoodProducts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get barcode => text().nullable()();
  RealColumn get caloriesPer100g => real()();
  RealColumn get proteinPer100g => real()();
  RealColumn get carbsPer100g => real()();
  RealColumn get fatPer100g => real()();
  RealColumn get fiberPer100g => real()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('FoodLogEntryRow')
class FoodLogEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get mealCategory => textEnum<MealCategory>()();
  TextColumn get name => text()();
  RealColumn get grams => real()();
  RealColumn get calories => real()();
  RealColumn get proteinGrams => real()();
  RealColumn get carbsGrams => real()();
  RealColumn get fatGrams => real()();
  RealColumn get fiberGrams => real()();
  TextColumn get note => text().nullable()();
}

@DataClassName('FavoriteFoodRow')
class FavoriteFoods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get grams => real()();
  RealColumn get calories => real()();
  RealColumn get proteinGrams => real()();
  RealColumn get carbsGrams => real()();
  RealColumn get fatGrams => real()();
  RealColumn get fiberGrams => real()();
}

@DataClassName('SavedMealRow')
class SavedMeals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('MealItemRow')
class MealItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get savedMealId => integer().references(SavedMeals, #id)();
  TextColumn get name => text()();
  RealColumn get grams => real()();
  RealColumn get calories => real()();
  RealColumn get proteinGrams => real()();
  RealColumn get carbsGrams => real()();
  RealColumn get fatGrams => real()();
  RealColumn get fiberGrams => real()();
}

@DataClassName('MealTemplateRow')
class MealTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get category => textEnum<MealCategory>()();
  RealColumn get calories => real()();
  RealColumn get proteinGrams => real()();
  RealColumn get carbsGrams => real()();
  RealColumn get fatGrams => real()();
  RealColumn get fiberGrams => real()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('TrainingSessionRow')
class TrainingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => textEnum<TrainingType>()();
  IntColumn get durationMinutes => integer()();
  IntColumn get rpe => integer()();
  RealColumn get bodyWeightKg => real()();
  RealColumn get estimatedCaloriesBurned => real()();
  TextColumn get note => text().nullable()();
}

@DataClassName('WeightLogRow')
class WeightLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  RealColumn get weightKg => real()();
  TextColumn get note => text().nullable()();
}

@DataClassName('BodyMeasurementLogRow')
class BodyMeasurementLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  RealColumn get waistCm => real().nullable()();
  RealColumn get chestCm => real().nullable()();
  RealColumn get hipsCm => real().nullable()();
  RealColumn get armCm => real().nullable()();
  RealColumn get thighCm => real().nullable()();
}

@DataClassName('DayStatusRow')
class DayStatuses extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => textEnum<DayStatusType>()();
}

@DataClassName('DailyTargetSnapshotRow')
class DailyTargetSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get goalMode => textEnum<GoalMode>()();
  TextColumn get goalPace => textEnum<GoalPace>()();
  RealColumn get calories => real()();
  RealColumn get proteinGrams => real()();
  RealColumn get carbsGrams => real()();
  RealColumn get fatGrams => real()();
  RealColumn get fiberGrams => real()();
  RealColumn get trainingCalories => real()();
}

@DriftDatabase(
  tables: [
    UserProfiles,
    GoalPeriods,
    FoodProducts,
    FoodLogEntries,
    FavoriteFoods,
    SavedMeals,
    MealItems,
    MealTemplates,
    TrainingSessions,
    WeightLogs,
    BodyMeasurementLogs,
    DayStatuses,
    DailyTargetSnapshots,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 3;

  /// Nog geen echte gebruikers vóór lancering, dus schema-wijzigingen tijdens
  /// deze ontwikkelfase krijgen een destructieve migratie (alles droppen en
  /// opnieuw aanmaken) i.p.v. losse per-versie upgrade-stappen te onderhouden.
  /// Vervang dit door echte migraties zodra de app data heeft die het waard
  /// is om te bewaren.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (Migrator m, int from, int to) async {
          for (final table in allTables) {
            await m.deleteTable(table.actualTableName);
          }
          await m.createAll();
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'whey_mate.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
