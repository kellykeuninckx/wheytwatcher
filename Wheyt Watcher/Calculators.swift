import Foundation

struct MacroTarget {
    let calories: Double
    let proteinGrams: Double
    let carbsGrams: Double
    let fatGrams: Double
    let fiberGrams: Double
    let bmr: Double
    let estimatedMaintenanceCalories: Double
    let trainingCalories: Double
}

enum MacroCalculator {
    static func calculate(for profile: UserProfile, extraTrainingCalories: Double = 0) -> MacroTarget {
        let bmr: Double

        switch profile.sex {
        case .male:
            bmr = 10 * profile.currentWeightKg + 6.25 * profile.heightCm - 5 * Double(profile.age) + 5
        case .female:
            bmr = 10 * profile.currentWeightKg + 6.25 * profile.heightCm - 5 * Double(profile.age) - 161
        }

        let maintenance = bmr * profile.activityLevel.multiplier
        let adjustment = maintenance * profile.goalPace.calorieAdjustmentPercentage(for: profile.goalMode)
        let targetCalories = maintenance + adjustment + extraTrainingCalories

        let proteinMultiplier: Double
        let fatMultiplier: Double

        switch profile.goalMode {
        case .cut:
            proteinMultiplier = 2.2
            fatMultiplier = 0.7
        case .maintenance:
            proteinMultiplier = 2.0
            fatMultiplier = 0.8
        case .bulk:
            proteinMultiplier = 1.8
            fatMultiplier = 0.8
        }

        let protein = profile.currentWeightKg * proteinMultiplier
        let fat = profile.currentWeightKg * fatMultiplier
        let fiber = 30.0

        let caloriesFromProtein = protein * 4
        let caloriesFromFat = fat * 9
        let remainingCalories = max(targetCalories - caloriesFromProtein - caloriesFromFat, 0)
        let carbs = remainingCalories / 4

        return MacroTarget(
            calories: targetCalories,
            proteinGrams: protein,
            carbsGrams: carbs,
            fatGrams: fat,
            fiberGrams: fiber,
            bmr: bmr,
            estimatedMaintenanceCalories: maintenance,
            trainingCalories: extraTrainingCalories
        )
    }
}

enum TrainingCalculator {
    static func estimateCalories(
        type: TrainingType,
        durationMinutes: Int,
        rpe: Int,
        bodyWeightKg: Double
    ) -> Double {
        let clampedRPE = min(max(rpe, 1), 10)
        let range = type.metRange

        let position = Double(clampedRPE - 1) / 9.0
        let met = range.lowerBound + ((range.upperBound - range.lowerBound) * position)

        return met * 3.5 * bodyWeightKg / 200.0 * Double(durationMinutes)
    }
}

//
//  Calculators.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//

