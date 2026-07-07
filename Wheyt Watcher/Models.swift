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

    @Relationship(deleteRule: .cascade, inverse: \GoalPeriod.profile)
    var goalPeriods: [GoalPeriod] = []

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

    /// De doelperiode waar de gebruiker op dit moment in zit (indien aanwezig).
    var activeGoalPeriod: GoalPeriod? {
        goalPeriods.first { $0.isActive }
    }

    /// Afgeronde/gewisselde doelperiodes, nieuwste eerst — voor geschiedenis.
    var pastGoalPeriods: [GoalPeriod] {
        goalPeriods
            .filter { !$0.isActive }
            .sorted { $0.startDate > $1.startDate }
    }

    /// Rondt de actieve periode af (indien aanwezig) en start een nieuwe.
    /// Wordt gebruikt vanuit ProfileView en vanuit de "periode afgelopen"-flow.
    func startNewGoalPeriod(mode: GoalMode, pace: GoalPace, durationWeeks: Int) {
        if let current = activeGoalPeriod {
            current.isActive = false
            current.completedAt = Date()
        }

        self.goalMode = mode
        self.goalPace = pace

        let newPeriod = GoalPeriod(
            startDate: Date(),
            durationWeeks: durationWeeks,
            goalMode: mode,
            goalPace: pace,
            isActive: true
        )
        newPeriod.profile = self
        goalPeriods.append(newPeriod)
    }
}

@Model
final class GoalPeriod {
    var startDate: Date
    var durationWeeks: Int
    var goalMode: GoalMode
    var goalPace: GoalPace
    var isActive: Bool
    var completedAt: Date?
    var profile: UserProfile?

    init(
        startDate: Date,
        durationWeeks: Int,
        goalMode: GoalMode,
        goalPace: GoalPace,
        isActive: Bool = true
    ) {
        self.startDate = startDate
        self.durationWeeks = durationWeeks
        self.goalMode = goalMode
        self.goalPace = goalPace
        self.isActive = isActive
        self.completedAt = nil
    }

    var endDate: Date {
        Calendar.current.date(
            byAdding: .weekOfYear,
            value: durationWeeks,
            to: Calendar.current.startOfDay(for: startDate)
        ) ?? startDate
    }

    /// 1-based weeknummer waarin de gebruiker nu zit, geclampt tussen 1 en durationWeeks.
    var currentWeekNumber: Int {
        let days = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: startDate),
            to: Calendar.current.startOfDay(for: Date())
        ).day ?? 0

        return min(max(days / 7 + 1, 1), durationWeeks)
    }

    var weeksRemaining: Int {
        max(durationWeeks - currentWeekNumber, 0)
    }

    var hasEnded: Bool {
        Calendar.current.startOfDay(for: Date()) >= Calendar.current.startOfDay(for: endDate)
    }
}

/// Geadviseerde en standaard-duur per doel/tempo-combinatie, met onderbouwing voor de gebruiker.
/// Dit zijn algemene, in de fitnesswereld gangbare vuistregels (geen individueel medisch advies) —
/// bewust op één plek verzameld zodat je de getallen/teksten makkelijk kan bijstellen.
enum GoalDurationAdvisor {

    static func recommendedWeeks(for mode: GoalMode, pace: GoalPace) -> Int {
        switch mode {
        case .maintenance:
            return 12
        case .cut:
            switch pace {
            case .conservative: return 12
            case .normal: return 8
            case .aggressive: return 6
            }
        case .bulk:
            switch pace {
            case .conservative: return 16
            case .normal: return 12
            case .aggressive: return 8
            }
        }
    }

    static func adviceText(for mode: GoalMode, pace: GoalPace) -> String {
        switch mode {
        case .maintenance:
            return "Bij onderhoud houden we standaard 12 weken aan. Zo verzamelt de app genoeg data om je trend te tonen, en evalueren we daarna of je wil bijsturen."

        case .cut:
            switch pace {
            case .conservative:
                return "Een voorzichtige cut duurt meestal 10–12 weken. Het kleinere calorietekort beschermt je spiermassa beter, maar vraagt meer geduld."
            case .normal:
                return "Een normale cut duurt meestal 8 weken — voor de meeste mensen een goede balans tussen tempo en het behouden van spiermassa."
            case .aggressive:
                return "Een agressieve cut duurt meestal 6 weken. Door het grotere tekort gaat het sneller, maar we raden af dit langer vol te houden: het risico op spierverlies en terugval neemt toe."
            }

        case .bulk:
            switch pace {
            case .conservative:
                return "Een voorzichtige bulk duurt meestal 14–16 weken. Langzaam aankomen beperkt vetopslag, maar kost meer tijd."
            case .normal:
                return "Een normale bulk duurt meestal 10–12 weken — een gangbare balans tussen spiergroei en vetopslag."
            case .aggressive:
                return "Een agressieve bulk duurt meestal 8 weken. Je komt sneller aan, maar met meer kans op overtollig vet — hou dit kort en evalueer daarna opnieuw."
            }
        }
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
