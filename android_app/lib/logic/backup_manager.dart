import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/database.dart';

/// Poort van `BackupManager.swift` + `BackupModels.swift`: exporteert alle data
/// naar één JSON-bestand en zet een eerdere back-up terug (vervangt alles).
/// Datums als ISO8601, enums als naam. Back-ups zijn bedoeld binnen Android
/// (net als iOS z'n lokale data) — geen cross-platform-garantie.
class BackupManager {
  BackupManager._();

  static String _iso(DateTime d) => d.toIso8601String();
  static DateTime _date(dynamic s) => DateTime.parse(s as String);

  static T _enumByName<T extends Enum>(List<T> values, dynamic name, T fallback) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }

  // MARK: - Export

  static Future<String> buildJson(AppDatabase db) async {
    final profile = await db.select(db.userProfiles).getSingleOrNull();
    final goalPeriods = await db.select(db.goalPeriods).get();
    final foodEntries = await db.select(db.foodLogEntries).get();
    final trainings = await db.select(db.trainingSessions).get();
    final weightLogs = await db.select(db.weightLogs).get();
    final measurementLogs = await db.select(db.bodyMeasurementLogs).get();
    final dayStatuses = await db.select(db.dayStatuses).get();
    final snapshots = await db.select(db.dailyTargetSnapshots).get();
    final favorites = await db.select(db.favoriteFoods).get();
    final savedMeals = await db.select(db.savedMeals).get();
    final mealItems = await db.select(db.mealItems).get();
    final foodProducts = await db.select(db.foodProducts).get();
    final mealTemplates = await db.select(db.mealTemplates).get();

    final payload = <String, dynamic>{
      'exportedAt': _iso(DateTime.now()),
      'profile': profile == null
          ? null
          : {
              'name': profile.name,
              'age': profile.age,
              'sex': profile.sex.name,
              'heightCm': profile.heightCm,
              'currentWeightKg': profile.currentWeightKg,
              'targetWeightKg': profile.targetWeightKg,
              'estimatedBodyFatPercentage': profile.estimatedBodyFatPercentage,
              'goalMode': profile.goalMode.name,
              'goalPace': profile.goalPace.name,
              'activityLevel': profile.activityLevel.name,
              'createdAt': _iso(profile.createdAt),
            },
      'goalPeriods': [
        for (final p in goalPeriods)
          {
            'startDate': _iso(p.startDate),
            'durationWeeks': p.durationWeeks,
            'goalMode': p.goalMode.name,
            'goalPace': p.goalPace.name,
            'isActive': p.isActive,
            'completedAt': p.completedAt == null ? null : _iso(p.completedAt!),
            'calorieAdjustment': p.calorieAdjustment,
            'lastCheckInDate': p.lastCheckInDate == null ? null : _iso(p.lastCheckInDate!),
          }
      ],
      'foodEntries': [
        for (final e in foodEntries)
          {
            'date': _iso(e.date),
            'mealCategory': e.mealCategory.name,
            'name': e.name,
            'grams': e.grams,
            'calories': e.calories,
            'proteinGrams': e.proteinGrams,
            'carbsGrams': e.carbsGrams,
            'fatGrams': e.fatGrams,
            'fiberGrams': e.fiberGrams,
            'note': e.note,
          }
      ],
      'trainings': [
        for (final t in trainings)
          {
            'date': _iso(t.date),
            'type': t.type.name,
            'durationMinutes': t.durationMinutes,
            'rpe': t.rpe,
            'bodyWeightKg': t.bodyWeightKg,
            'estimatedCaloriesBurned': t.estimatedCaloriesBurned,
            'note': t.note,
          }
      ],
      'weightLogs': [
        for (final w in weightLogs) {'date': _iso(w.date), 'weightKg': w.weightKg, 'note': w.note}
      ],
      'measurementLogs': [
        for (final m in measurementLogs)
          {'date': _iso(m.date), 'waistCm': m.waistCm, 'chestCm': m.chestCm, 'hipsCm': m.hipsCm, 'armCm': m.armCm, 'thighCm': m.thighCm}
      ],
      'dayStatuses': [
        for (final s in dayStatuses) {'date': _iso(s.date), 'type': s.type.name}
      ],
      'snapshots': [
        for (final s in snapshots)
          {
            'date': _iso(s.date),
            'goalMode': s.goalMode.name,
            'goalPace': s.goalPace.name,
            'calories': s.calories,
            'proteinGrams': s.proteinGrams,
            'carbsGrams': s.carbsGrams,
            'fatGrams': s.fatGrams,
            'fiberGrams': s.fiberGrams,
            'trainingCalories': s.trainingCalories,
          }
      ],
      'favorites': [
        for (final f in favorites)
          {'name': f.name, 'grams': f.grams, 'calories': f.calories, 'proteinGrams': f.proteinGrams, 'carbsGrams': f.carbsGrams, 'fatGrams': f.fatGrams, 'fiberGrams': f.fiberGrams}
      ],
      'savedMeals': [
        for (final meal in savedMeals)
          {
            'name': meal.name,
            'createdAt': _iso(meal.createdAt),
            'items': [
              for (final item in mealItems.where((i) => i.savedMealId == meal.id))
                {'name': item.name, 'grams': item.grams, 'calories': item.calories, 'proteinGrams': item.proteinGrams, 'carbsGrams': item.carbsGrams, 'fatGrams': item.fatGrams, 'fiberGrams': item.fiberGrams}
            ],
          }
      ],
      'foodProducts': [
        for (final p in foodProducts)
          {
            'name': p.name,
            'brand': p.brand,
            'barcode': p.barcode,
            'caloriesPer100g': p.caloriesPer100g,
            'proteinPer100g': p.proteinPer100g,
            'carbsPer100g': p.carbsPer100g,
            'fatPer100g': p.fatPer100g,
            'fiberPer100g': p.fiberPer100g,
            'createdAt': _iso(p.createdAt),
          }
      ],
      'mealTemplates': [
        for (final t in mealTemplates)
          {
            'name': t.name,
            'category': t.category.name,
            'calories': t.calories,
            'proteinGrams': t.proteinGrams,
            'carbsGrams': t.carbsGrams,
            'fatGrams': t.fatGrams,
            'fiberGrams': t.fiberGrams,
            'createdAt': _iso(t.createdAt),
          }
      ],
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  // MARK: - Import (vervangt alles)

  static Future<void> restore(AppDatabase db, String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    await db.transaction(() async {
      // Alles wissen (mealItems vóór savedMeals i.v.m. de foreign key).
      await db.delete(db.mealItems).go();
      await db.delete(db.savedMeals).go();
      await db.delete(db.goalPeriods).go();
      await db.delete(db.userProfiles).go();
      await db.delete(db.foodLogEntries).go();
      await db.delete(db.trainingSessions).go();
      await db.delete(db.weightLogs).go();
      await db.delete(db.bodyMeasurementLogs).go();
      await db.delete(db.dayStatuses).go();
      await db.delete(db.dailyTargetSnapshots).go();
      await db.delete(db.favoriteFoods).go();
      await db.delete(db.foodProducts).go();
      await db.delete(db.mealTemplates).go();

      int? profileId;
      final profile = data['profile'] as Map<String, dynamic>?;
      if (profile != null) {
        profileId = await db.into(db.userProfiles).insert(UserProfilesCompanion.insert(
          name: profile['name'] as String,
          age: profile['age'] as int,
          sex: _enumByName(Sex.values, profile['sex'], Sex.male),
          heightCm: (profile['heightCm'] as num).toDouble(),
          currentWeightKg: (profile['currentWeightKg'] as num).toDouble(),
          targetWeightKg: Value((profile['targetWeightKg'] as num?)?.toDouble()),
          estimatedBodyFatPercentage: Value((profile['estimatedBodyFatPercentage'] as num?)?.toDouble()),
          goalMode: _enumByName(GoalMode.values, profile['goalMode'], GoalMode.maintenance),
          goalPace: _enumByName(GoalPace.values, profile['goalPace'], GoalPace.normal),
          activityLevel: _enumByName(ActivityLevel.values, profile['activityLevel'], ActivityLevel.moderate),
          createdAt: _date(profile['createdAt']),
        ));
      }

      for (final p in (data['goalPeriods'] as List? ?? [])) {
        await db.into(db.goalPeriods).insert(GoalPeriodsCompanion.insert(
          profileId: Value(profileId),
          startDate: _date(p['startDate']),
          durationWeeks: p['durationWeeks'] as int,
          goalMode: _enumByName(GoalMode.values, p['goalMode'], GoalMode.maintenance),
          goalPace: _enumByName(GoalPace.values, p['goalPace'], GoalPace.normal),
          isActive: Value(p['isActive'] as bool? ?? false),
          completedAt: Value(p['completedAt'] == null ? null : _date(p['completedAt'])),
          calorieAdjustment: Value((p['calorieAdjustment'] as num?)?.toDouble() ?? 0),
          lastCheckInDate: Value(p['lastCheckInDate'] == null ? null : _date(p['lastCheckInDate'])),
        ));
      }

      for (final e in (data['foodEntries'] as List? ?? [])) {
        await db.into(db.foodLogEntries).insert(FoodLogEntriesCompanion.insert(
          date: _date(e['date']),
          mealCategory: _enumByName(MealCategory.values, e['mealCategory'], MealCategory.other),
          name: e['name'] as String,
          grams: (e['grams'] as num).toDouble(),
          calories: (e['calories'] as num).toDouble(),
          proteinGrams: (e['proteinGrams'] as num).toDouble(),
          carbsGrams: (e['carbsGrams'] as num).toDouble(),
          fatGrams: (e['fatGrams'] as num).toDouble(),
          fiberGrams: (e['fiberGrams'] as num).toDouble(),
          note: Value(e['note'] as String?),
        ));
      }

      for (final t in (data['trainings'] as List? ?? [])) {
        await db.into(db.trainingSessions).insert(TrainingSessionsCompanion.insert(
          date: _date(t['date']),
          type: _enumByName(TrainingType.values, t['type'], TrainingType.other),
          durationMinutes: t['durationMinutes'] as int,
          rpe: t['rpe'] as int,
          bodyWeightKg: (t['bodyWeightKg'] as num).toDouble(),
          estimatedCaloriesBurned: (t['estimatedCaloriesBurned'] as num).toDouble(),
          note: Value(t['note'] as String?),
        ));
      }

      for (final w in (data['weightLogs'] as List? ?? [])) {
        await db.into(db.weightLogs).insert(WeightLogsCompanion.insert(
          date: _date(w['date']),
          weightKg: (w['weightKg'] as num).toDouble(),
          note: Value(w['note'] as String?),
        ));
      }

      for (final m in (data['measurementLogs'] as List? ?? [])) {
        await db.into(db.bodyMeasurementLogs).insert(BodyMeasurementLogsCompanion.insert(
          date: _date(m['date']),
          waistCm: Value((m['waistCm'] as num?)?.toDouble()),
          chestCm: Value((m['chestCm'] as num?)?.toDouble()),
          hipsCm: Value((m['hipsCm'] as num?)?.toDouble()),
          armCm: Value((m['armCm'] as num?)?.toDouble()),
          thighCm: Value((m['thighCm'] as num?)?.toDouble()),
        ));
      }

      for (final s in (data['dayStatuses'] as List? ?? [])) {
        await db.into(db.dayStatuses).insert(DayStatusesCompanion.insert(
          date: _date(s['date']),
          type: _enumByName(DayStatusType.values, s['type'], DayStatusType.restDay),
        ));
      }

      for (final s in (data['snapshots'] as List? ?? [])) {
        await db.into(db.dailyTargetSnapshots).insert(DailyTargetSnapshotsCompanion.insert(
          date: _date(s['date']),
          goalMode: _enumByName(GoalMode.values, s['goalMode'], GoalMode.maintenance),
          goalPace: _enumByName(GoalPace.values, s['goalPace'], GoalPace.normal),
          calories: (s['calories'] as num).toDouble(),
          proteinGrams: (s['proteinGrams'] as num).toDouble(),
          carbsGrams: (s['carbsGrams'] as num).toDouble(),
          fatGrams: (s['fatGrams'] as num).toDouble(),
          fiberGrams: (s['fiberGrams'] as num).toDouble(),
          trainingCalories: (s['trainingCalories'] as num).toDouble(),
        ));
      }

      for (final f in (data['favorites'] as List? ?? [])) {
        await db.into(db.favoriteFoods).insert(FavoriteFoodsCompanion.insert(
          name: f['name'] as String,
          grams: (f['grams'] as num).toDouble(),
          calories: (f['calories'] as num).toDouble(),
          proteinGrams: (f['proteinGrams'] as num).toDouble(),
          carbsGrams: (f['carbsGrams'] as num).toDouble(),
          fatGrams: (f['fatGrams'] as num).toDouble(),
          fiberGrams: (f['fiberGrams'] as num).toDouble(),
        ));
      }

      for (final meal in (data['savedMeals'] as List? ?? [])) {
        final mealId = await db.into(db.savedMeals).insert(SavedMealsCompanion.insert(
          name: meal['name'] as String,
          createdAt: _date(meal['createdAt']),
        ));
        for (final item in (meal['items'] as List? ?? [])) {
          await db.into(db.mealItems).insert(MealItemsCompanion.insert(
            savedMealId: mealId,
            name: item['name'] as String,
            grams: (item['grams'] as num).toDouble(),
            calories: (item['calories'] as num).toDouble(),
            proteinGrams: (item['proteinGrams'] as num).toDouble(),
            carbsGrams: (item['carbsGrams'] as num).toDouble(),
            fatGrams: (item['fatGrams'] as num).toDouble(),
            fiberGrams: (item['fiberGrams'] as num).toDouble(),
          ));
        }
      }

      for (final p in (data['foodProducts'] as List? ?? [])) {
        await db.into(db.foodProducts).insert(FoodProductsCompanion.insert(
          name: p['name'] as String,
          brand: Value(p['brand'] as String?),
          barcode: Value(p['barcode'] as String?),
          caloriesPer100g: (p['caloriesPer100g'] as num).toDouble(),
          proteinPer100g: (p['proteinPer100g'] as num).toDouble(),
          carbsPer100g: (p['carbsPer100g'] as num).toDouble(),
          fatPer100g: (p['fatPer100g'] as num).toDouble(),
          fiberPer100g: (p['fiberPer100g'] as num).toDouble(),
          createdAt: _date(p['createdAt']),
        ));
      }

      for (final t in (data['mealTemplates'] as List? ?? [])) {
        await db.into(db.mealTemplates).insert(MealTemplatesCompanion.insert(
          name: t['name'] as String,
          category: _enumByName(MealCategory.values, t['category'], MealCategory.other),
          calories: (t['calories'] as num).toDouble(),
          proteinGrams: (t['proteinGrams'] as num).toDouble(),
          carbsGrams: (t['carbsGrams'] as num).toDouble(),
          fatGrams: (t['fatGrams'] as num).toDouble(),
          fiberGrams: (t['fiberGrams'] as num).toDouble(),
          createdAt: _date(t['createdAt']),
        ));
      }
    });
  }
}
