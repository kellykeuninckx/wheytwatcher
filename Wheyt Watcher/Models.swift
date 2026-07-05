//import Foundation
import SwiftData
import Foundation

enum Sex: String, Codable, CaseIterable, Identifiable {
    case male = "Man"
    case female = "Vrouw"

    var id: String { rawValue }
}

enum GoalMode: String, Codable, CaseIterable, Identifiable {
    case cut = "Cut"
    case maintenance = "Onderhoud"
    case bulk = "Bulk"

    var id: String { rawValue }

    var shortDescription: String {
        switch self {
        case .cut:
            return "Vetpercentage omlaag, gains beschermen"
        case .maintenance:
            return "Stabiel blijven, performance bewaken"
        case .bulk:
            return "Aankomen, spiermassa opbouwen"
        }
    }
}

enum GoalPace: String, Codable, CaseIterable, Identifiable {
    case conservative = "Voorzichtig"
    case normal = "Normaal"
    case aggressive = "Agressief"

    var id: String { rawValue }

    func calorieAdjustmentPercentage(for mode: GoalMode) -> Double {
        switch mode {
        case .cut:
            switch self {
            case .conservative:
                return -0.10
            case .normal:
                return -0.15
            case .aggressive:
                return -0.20
            }

        case .maintenance:
            return 0.0

        case .bulk:
            switch self {
            case .conservative:
                return 0.05
            case .normal:
                return 0.10
            case .aggressive:
                return 0.15
            }
        }
    }
}

enum ActivityLevel: String, Codable, CaseIterable, Identifiable {
    case sedentary = "Zittend"
    case light = "Licht actief"
    case moderate = "Redelijk actief"
    case active = "Actief"

    var id: String { rawValue }

    var multiplier: Double {
        switch self {
        case .sedentary:
            return 1.20
        case .light:
            return 1.35
        case .moderate:
            return 1.45
        case .active:
            return 1.60
        }
    }
}

enum TrainingType: String, Codable, CaseIterable, Identifiable {
    case heavyStrength = "Kracht zwaar"
    case hypertrophy = "Kracht hypertrofie"
    case hyrox = "Hyrox / conditioning"
    case gymnastics = "Gymnastics / skill"
    case running = "Hardlopen"
    case walking = "Wandelen"
    case boxing = "Boksen"
    case other = "Overig"

    var id: String { rawValue }

    var metRange: ClosedRange<Double> {
        switch self {
        case .heavyStrength:
            return 4.5...7.0
        case .hypertrophy:
            return 4.0...6.5
        case .hyrox:
            return 7.0...11.0
        case .gymnastics:
            return 3.5...6.0
        case .running:
            return 7.0...12.0
        case .walking:
            return 2.5...4.0
        case .boxing:
            return 6.0...10.0
        case .other:
            return 3.0...8.0
        }
    }
}

enum MealCategory: String, Codable, CaseIterable, Identifiable {
    case breakfast = "Ontbijt"
    case lunch = "Lunch"
    case dinner = "Avondeten"
    case snack = "Snack"
    case preWorkout = "Pre-workout"
    case postWorkout = "Post-workout"
    case other = "Overig"

    var id: String { rawValue }
}

@Model
final class UserProfile {
    var name: String
    var age: Int
    var sex: Sex
    var heightCm: Double
    var currentWeightKg: Double
    var estimatedBodyFatPercentage: Double?
    var goalMode: GoalMode
    var goalPace: GoalPace
    var activityLevel: ActivityLevel
    var createdAt: Date

    init(
        name: String,
        age: Int,
        sex: Sex,
        heightCm: Double,
        currentWeightKg: Double,
        estimatedBodyFatPercentage: Double? = nil,
        goalMode: GoalMode,
        goalPace: GoalPace,
        activityLevel: ActivityLevel
    ) {
        self.name = name
        self.age = age
        self.sex = sex
        self.heightCm = heightCm
        self.currentWeightKg = currentWeightKg
        self.estimatedBodyFatPercentage = estimatedBodyFatPercentage
        self.goalMode = goalMode
        self.goalPace = goalPace
        self.activityLevel = activityLevel
        self.createdAt = Date()
    }
}

@Model
final class FoodProduct {
    var name: String
    var brand: String?
    var barcode: String?
    var caloriesPer100g: Double
    var proteinPer100g: Double
    var carbsPer100g: Double
    var fatPer100g: Double
    var fiberPer100g: Double
    var createdAt: Date

    init(
        name: String,
        brand: String? = nil,
        barcode: String? = nil,
        caloriesPer100g: Double,
        proteinPer100g: Double,
        carbsPer100g: Double,
        fatPer100g: Double,
        fiberPer100g: Double
    ) {
        self.name = name
        self.brand = brand
        self.barcode = barcode
        self.caloriesPer100g = caloriesPer100g
        self.proteinPer100g = proteinPer100g
        self.carbsPer100g = carbsPer100g
        self.fatPer100g = fatPer100g
        self.fiberPer100g = fiberPer100g
        self.createdAt = Date()
    }
}

@Model
final class FoodLogEntry {
    var date: Date
    var mealCategory: MealCategory
    var name: String
    var grams: Double
    var calories: Double
    var proteinGrams: Double
    var carbsGrams: Double
    var fatGrams: Double
    var fiberGrams: Double
    var note: String?

    init(
        date: Date,
        mealCategory: MealCategory,
        name: String,
        grams: Double,
        calories: Double,
        proteinGrams: Double,
        carbsGrams: Double,
        fatGrams: Double,
        fiberGrams: Double,
        note: String? = nil
    ) {
        self.date = date
        self.mealCategory = mealCategory
        self.name = name
        self.grams = grams
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
        self.note = note
    }
}

@Model
final class MealTemplate {
    var name: String
    var category: MealCategory
    var calories: Double
    var proteinGrams: Double
    var carbsGrams: Double
    var fatGrams: Double
    var fiberGrams: Double
    var createdAt: Date

    init(
        name: String,
        category: MealCategory,
        calories: Double,
        proteinGrams: Double,
        carbsGrams: Double,
        fatGrams: Double,
        fiberGrams: Double
    ) {
        self.name = name
        self.category = category
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
        self.createdAt = Date()
    }
}

@Model
final class TrainingSession {
    var date: Date
    var type: TrainingType
    var durationMinutes: Int
    var rpe: Int
    var bodyWeightKg: Double
    var estimatedCaloriesBurned: Double
    var note: String?

    init(
        date: Date,
        type: TrainingType,
        durationMinutes: Int,
        rpe: Int,
        bodyWeightKg: Double,
        estimatedCaloriesBurned: Double,
        note: String? = nil
    ) {
        self.date = date
        self.type = type
        self.durationMinutes = durationMinutes
        self.rpe = rpe
        self.bodyWeightKg = bodyWeightKg
        self.estimatedCaloriesBurned = estimatedCaloriesBurned
        self.note = note
    }
}

@Model
final class WeightLog {
    var date: Date
    var weightKg: Double
    var note: String?

    init(date: Date, weightKg: Double, note: String? = nil) {
        self.date = date
        self.weightKg = weightKg
        self.note = note
    }
}

@Model
final class DailyTargetSnapshot {
    var date: Date
    var goalMode: GoalMode
    var goalPace: GoalPace
    var calories: Double
    var proteinGrams: Double
    var carbsGrams: Double
    var fatGrams: Double
    var fiberGrams: Double
    var trainingCalories: Double

    init(
        date: Date,
        goalMode: GoalMode,
        goalPace: GoalPace,
        calories: Double,
        proteinGrams: Double,
        carbsGrams: Double,
        fatGrams: Double,
        fiberGrams: Double,
        trainingCalories: Double
    ) {
        self.date = date
        self.goalMode = goalMode
        self.goalPace = goalPace
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
        self.fiberGrams = fiberGrams
        self.trainingCalories = trainingCalories
    }
}

//  Models.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 03/07/2026.
//

