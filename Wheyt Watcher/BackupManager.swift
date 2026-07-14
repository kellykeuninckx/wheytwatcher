import Foundation
import SwiftData

enum BackupManager {

    // MARK: - Export

    static func buildPayload(
        profile: UserProfile?,
        foodEntries: [FoodLogEntry],
        trainings: [TrainingSession],
        weightLogs: [WeightLog],
        measurementLogs: [BodyMeasurementLog],
        dayStatuses: [DayStatus],
        snapshots: [DailyTargetSnapshot],
        favorites: [FavoriteFood],
        savedMeals: [SavedMeal],
        foodProducts: [FoodProduct],
        mealTemplates: [MealTemplate]
    ) -> BackupPayload {

        BackupPayload(
            exportedAt: Date(),

            profile: profile.map { p in
                ProfileDTO(
                    name: p.name,
                    age: p.age,
                    sex: p.sex.rawValue,
                    heightCm: p.heightCm,
                    currentWeightKg: p.currentWeightKg,
                    estimatedBodyFatPercentage: p.estimatedBodyFatPercentage,
                    goalMode: p.goalMode.rawValue,
                    goalPace: p.goalPace.rawValue,
                    activityLevel: p.activityLevel.rawValue,
                    createdAt: p.createdAt
                )
            },

            goalPeriods: (profile?.goalPeriods ?? []).map { period in
                GoalPeriodDTO(
                    startDate: period.startDate,
                    durationWeeks: period.durationWeeks,
                    goalMode: period.goalMode.rawValue,
                    goalPace: period.goalPace.rawValue,
                    isActive: period.isActive,
                    completedAt: period.completedAt,
                    calorieAdjustment: period.calorieAdjustment,
                    lastCheckInDate: period.lastCheckInDate
                )
            },

            foodEntries: foodEntries.map { entry in
                FoodLogEntryDTO(
                    date: entry.date,
                    mealCategory: entry.mealCategory.rawValue,
                    name: entry.name,
                    grams: entry.grams,
                    calories: entry.calories,
                    proteinGrams: entry.proteinGrams,
                    carbsGrams: entry.carbsGrams,
                    fatGrams: entry.fatGrams,
                    fiberGrams: entry.fiberGrams,
                    note: entry.note
                )
            },

            trainings: trainings.map { session in
                TrainingSessionDTO(
                    date: session.date,
                    type: session.type.rawValue,
                    durationMinutes: session.durationMinutes,
                    rpe: session.rpe,
                    bodyWeightKg: session.bodyWeightKg,
                    estimatedCaloriesBurned: session.estimatedCaloriesBurned,
                    note: session.note
                )
            },

            weightLogs: weightLogs.map { log in
                WeightLogDTO(date: log.date, weightKg: log.weightKg, note: log.note)
            },

            measurementLogs: measurementLogs.map { log in
                BodyMeasurementLogDTO(
                    date: log.date,
                    waistCm: log.waistCm,
                    chestCm: log.chestCm,
                    hipsCm: log.hipsCm,
                    armCm: log.armCm,
                    thighCm: log.thighCm
                )
            },

            dayStatuses: dayStatuses.map { status in
                DayStatusDTO(date: status.date, type: status.type.rawValue)
            },

            snapshots: snapshots.map { snapshot in
                DailyTargetSnapshotDTO(
                    date: snapshot.date,
                    goalMode: snapshot.goalMode.rawValue,
                    goalPace: snapshot.goalPace.rawValue,
                    calories: snapshot.calories,
                    proteinGrams: snapshot.proteinGrams,
                    carbsGrams: snapshot.carbsGrams,
                    fatGrams: snapshot.fatGrams,
                    fiberGrams: snapshot.fiberGrams,
                    trainingCalories: snapshot.trainingCalories
                )
            },

            favorites: favorites.map { favorite in
                FavoriteFoodDTO(
                    name: favorite.name,
                    grams: favorite.grams,
                    calories: favorite.calories,
                    proteinGrams: favorite.proteinGrams,
                    carbsGrams: favorite.carbsGrams,
                    fatGrams: favorite.fatGrams,
                    fiberGrams: favorite.fiberGrams
                )
            },

            savedMeals: savedMeals.map { meal in
                SavedMealDTO(
                    name: meal.name,
                    createdAt: meal.createdAt,
                    items: meal.items.map { item in
                        MealItemDTO(
                            name: item.name,
                            grams: item.grams,
                            calories: item.calories,
                            proteinGrams: item.proteinGrams,
                            carbsGrams: item.carbsGrams,
                            fatGrams: item.fatGrams,
                            fiberGrams: item.fiberGrams
                        )
                    }
                )
            },

            foodProducts: foodProducts.map { product in
                FoodProductDTO(
                    name: product.name,
                    brand: product.brand,
                    barcode: product.barcode,
                    caloriesPer100g: product.caloriesPer100g,
                    proteinPer100g: product.proteinPer100g,
                    carbsPer100g: product.carbsPer100g,
                    fatPer100g: product.fatPer100g,
                    fiberPer100g: product.fiberPer100g,
                    createdAt: product.createdAt
                )
            },

            mealTemplates: mealTemplates.map { template in
                MealTemplateDTO(
                    name: template.name,
                    category: template.category.rawValue,
                    calories: template.calories,
                    proteinGrams: template.proteinGrams,
                    carbsGrams: template.carbsGrams,
                    fatGrams: template.fatGrams,
                    fiberGrams: template.fiberGrams,
                    createdAt: template.createdAt
                )
            }
        )
    }

    static func encode(_ payload: BackupPayload) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(payload)
    }

    static func decode(_ data: Data) throws -> BackupPayload {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(BackupPayload.self, from: data)
    }

    // MARK: - Restore (destructief — vervangt alle huidige data, geen samenvoegen)

    static func restore(_ payload: BackupPayload, into context: ModelContext) throws {

        try context.delete(model: UserProfile.self)
        try context.delete(model: GoalPeriod.self)
        try context.delete(model: FoodLogEntry.self)
        try context.delete(model: TrainingSession.self)
        try context.delete(model: WeightLog.self)
        try context.delete(model: BodyMeasurementLog.self)
        try context.delete(model: DayStatus.self)
        try context.delete(model: DailyTargetSnapshot.self)
        try context.delete(model: FavoriteFood.self)
        try context.delete(model: SavedMeal.self)
        try context.delete(model: MealItem.self)
        try context.delete(model: FoodProduct.self)
        try context.delete(model: MealTemplate.self)

        if let profileDTO = payload.profile {
            let profile = UserProfile(
                name: profileDTO.name,
                age: profileDTO.age,
                sex: Sex(rawValue: profileDTO.sex) ?? .male,
                heightCm: profileDTO.heightCm,
                currentWeightKg: profileDTO.currentWeightKg,
                estimatedBodyFatPercentage: profileDTO.estimatedBodyFatPercentage,
                goalMode: GoalMode(rawValue: profileDTO.goalMode) ?? .maintenance,
                goalPace: GoalPace(rawValue: profileDTO.goalPace) ?? .normal,
                activityLevel: ActivityLevel(rawValue: profileDTO.activityLevel) ?? .moderate
            )
            context.insert(profile)

            for periodDTO in payload.goalPeriods {
                let period = GoalPeriod(
                    startDate: periodDTO.startDate,
                    durationWeeks: periodDTO.durationWeeks,
                    goalMode: GoalMode(rawValue: periodDTO.goalMode) ?? .maintenance,
                    goalPace: GoalPace(rawValue: periodDTO.goalPace) ?? .normal,
                    isActive: periodDTO.isActive
                )
                period.completedAt = periodDTO.completedAt
                period.calorieAdjustment = periodDTO.calorieAdjustment
                period.lastCheckInDate = periodDTO.lastCheckInDate
                period.profile = profile
                context.insert(period)
            }
        }

        for dto in payload.foodEntries {
            context.insert(FoodLogEntry(
                date: dto.date,
                mealCategory: MealCategory(rawValue: dto.mealCategory) ?? .other,
                name: dto.name,
                grams: dto.grams,
                calories: dto.calories,
                proteinGrams: dto.proteinGrams,
                carbsGrams: dto.carbsGrams,
                fatGrams: dto.fatGrams,
                fiberGrams: dto.fiberGrams,
                note: dto.note
            ))
        }

        for dto in payload.trainings {
            context.insert(TrainingSession(
                date: dto.date,
                type: TrainingType(rawValue: dto.type) ?? .other,
                durationMinutes: dto.durationMinutes,
                rpe: dto.rpe,
                bodyWeightKg: dto.bodyWeightKg,
                estimatedCaloriesBurned: dto.estimatedCaloriesBurned,
                note: dto.note
            ))
        }

        for dto in payload.weightLogs {
            context.insert(WeightLog(date: dto.date, weightKg: dto.weightKg, note: dto.note))
        }

        for dto in payload.measurementLogs {
            context.insert(BodyMeasurementLog(
                date: dto.date,
                waistCm: dto.waistCm,
                chestCm: dto.chestCm,
                hipsCm: dto.hipsCm,
                armCm: dto.armCm,
                thighCm: dto.thighCm
            ))
        }

        for dto in payload.dayStatuses {
            context.insert(DayStatus(date: dto.date, type: DayStatusType(rawValue: dto.type) ?? .restDay))
        }

        for dto in payload.snapshots {
            context.insert(DailyTargetSnapshot(
                date: dto.date,
                goalMode: GoalMode(rawValue: dto.goalMode) ?? .maintenance,
                goalPace: GoalPace(rawValue: dto.goalPace) ?? .normal,
                calories: dto.calories,
                proteinGrams: dto.proteinGrams,
                carbsGrams: dto.carbsGrams,
                fatGrams: dto.fatGrams,
                fiberGrams: dto.fiberGrams,
                trainingCalories: dto.trainingCalories
            ))
        }

        for dto in payload.favorites {
            context.insert(FavoriteFood(
                name: dto.name,
                grams: dto.grams,
                calories: dto.calories,
                proteinGrams: dto.proteinGrams,
                carbsGrams: dto.carbsGrams,
                fatGrams: dto.fatGrams,
                fiberGrams: dto.fiberGrams
            ))
        }

        for mealDTO in payload.savedMeals {
            let meal = SavedMeal(name: mealDTO.name, createdAt: mealDTO.createdAt)
            context.insert(meal)

            for itemDTO in mealDTO.items {
                let item = MealItem(
                    name: itemDTO.name,
                    grams: itemDTO.grams,
                    calories: itemDTO.calories,
                    proteinGrams: itemDTO.proteinGrams,
                    carbsGrams: itemDTO.carbsGrams,
                    fatGrams: itemDTO.fatGrams,
                    fiberGrams: itemDTO.fiberGrams
                )
                meal.items.append(item)
            }
        }

        for dto in payload.foodProducts {
            context.insert(FoodProduct(
                name: dto.name,
                brand: dto.brand,
                barcode: dto.barcode,
                caloriesPer100g: dto.caloriesPer100g,
                proteinPer100g: dto.proteinPer100g,
                carbsPer100g: dto.carbsPer100g,
                fatPer100g: dto.fatPer100g,
                fiberPer100g: dto.fiberPer100g
            ))
        }

        for dto in payload.mealTemplates {
            context.insert(MealTemplate(
                name: dto.name,
                category: MealCategory(rawValue: dto.category) ?? .other,
                calories: dto.calories,
                proteinGrams: dto.proteinGrams,
                carbsGrams: dto.carbsGrams,
                fatGrams: dto.fatGrams,
                fiberGrams: dto.fiberGrams
            ))
        }

        try context.save()
    }

}
