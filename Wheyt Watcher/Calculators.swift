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
    
    static func calculate(
        for profile: UserProfile,
        extraTrainingCalories: Double = 0,
        manualCalorieAdjustment: Double = 0
    ) -> MacroTarget {
        let bmr: Double

                switch profile.sex {
                case .male:
                    bmr = 10 * profile.currentWeightKg + 6.25 * profile.heightCm - 5 * Double(profile.age) + 5
                case .female:
                    bmr = 10 * profile.currentWeightKg + 6.25 * profile.heightCm - 5 * Double(profile.age) - 161
                }

        let maintenance = bmr * profile.activityLevel.multiplier
        let adjustment = maintenance * profile.goalPace.calorieAdjustmentPercentage(for: profile.goalMode);            let targetCalories = maintenance + adjustment + extraTrainingCalories + manualCalorieAdjustment

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
    static func calculate(
        for profile: UserProfile,
        goalMode: GoalMode,
        goalPace: GoalPace,
        extraTrainingCalories: Double = 0,
        manualCalorieAdjustment: Double = 0
    ) -> MacroTarget {

        let bmr: Double

        switch profile.sex {
        case .male:
            bmr = 10 * profile.currentWeightKg + 6.25 * profile.heightCm - 5 * Double(profile.age) + 5
        case .female:
            bmr = 10 * profile.currentWeightKg + 6.25 * profile.heightCm - 5 * Double(profile.age) - 161
        }

        let maintenance = bmr * profile.activityLevel.multiplier
        let adjustment = maintenance * goalPace.calorieAdjustmentPercentage(for: goalMode)
        let targetCalories = maintenance + adjustment + extraTrainingCalories + manualCalorieAdjustment

        let proteinMultiplier: Double
        let fatMultiplier: Double

        switch goalMode {
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

// MARK: - Slimme 2-wekelijkse check-in

enum AdaptiveCheckInResult {
    /// Niet genoeg betrouwbare data (logging en/of gewicht) om een advies op te baseren.
    case insufficientData(reason: String)
    /// Voortgang past bij het doel — geen aanpassing nodig.
    case onTrack(message: String)
    /// Voortgang blijft achter — voorstel om de calorieën met `kcal` bij te stellen.
    case suggestAdjustment(kcal: Double, reasoning: String)
}

enum AdaptiveCheckInEvaluator {

    /// Evalueert de laatste 14 dagen: genoeg gelogd? en past de gewichtstrend bij het doel?
    static func evaluate(
        period: GoalPeriod,
        foodEntries: [FoodLogEntry],
        weightLogs: [WeightLog],
        trainings: [TrainingSession],
        dayStatuses: [DayStatus] = []
    ) -> AdaptiveCheckInResult {

        let calendar = Calendar.current
        let windowStart = calendar.date(byAdding: .day, value: -14, to: Date()) ?? period.startDate

        let loggedDays = Set(
            foodEntries
                .filter { $0.date >= windowStart }
                .map { calendar.startOfDay(for: $0.date) }
        ).count

        let markedDays = Set(
            dayStatuses
                .filter { $0.date >= windowStart }
                .map { calendar.startOfDay(for: $0.date) }
        ).count

        // Gemarkeerde dagen (ziek/vakantie/rustdag) tellen niet mee als "moeten loggen".
        let trackableDays = max(14 - markedDays, 1)
        let loggingRate = Double(loggedDays) / Double(trackableDays)

        let markedDaysSet = Set(
            dayStatuses
                .filter { $0.date >= windowStart }
                .map { calendar.startOfDay(for: $0.date) }
        )

        let recentWeights = weightLogs.filter {
            $0.date >= windowStart && !markedDaysSet.contains(calendar.startOfDay(for: $0.date))
        }
        let trainingCount = trainings.filter { $0.date >= windowStart }.count

        guard loggingRate >= 0.7, recentWeights.count >= 3 else {
            return .insufficientData(
                reason: "Je hebt de afgelopen 2 weken niet consistent genoeg gelogd (voeding en/of gewicht) om een betrouwbaar advies te geven. We wachten nog even met een aanpassing — hoe beter je logt, hoe scherper het advies."
            )
        }

        guard let weeklyRate = weeklyWeightChangeRate(for: recentWeights) else {
            return .insufficientData(
                reason: "We hebben nog niet genoeg gewichtsdata deze periode om een trend te bepalen. We wachten nog even met een aanpassing."
            )
        }

        switch period.goalMode {

        case .cut:
            if weeklyRate > -0.1 {
                return .suggestAdjustment(
                    kcal: -100,
                    reasoning: "Je hebt de afgelopen 2 weken consistent gelogd en \(trainingCount)x getraind, maar je gewicht daalt nauwelijks. Advies: verlaag je caloriebehoefte met 100 kcal per dag."
                )
            }
            return .onTrack(message: "Je gewicht daalt zoals verwacht bij je cut. Ga zo door!")

        case .bulk:
            if weeklyRate < 0.1 {
                return .suggestAdjustment(
                    kcal: 100,
                    reasoning: "Je hebt de afgelopen 2 weken consistent gelogd en \(trainingCount)x getraind, maar je komt nauwelijks aan. Advies: verhoog je caloriebehoefte met 100 kcal per dag."
                )
            }
            return .onTrack(message: "Je gewicht stijgt zoals verwacht bij je bulk. Ga zo door!")

        case .maintenance:
            return .onTrack(message: "Je gewicht blijft stabiel — precies de bedoeling bij onderhoud.")

        }
    }

    /// Kleinste-kwadraten regressie over een voortschrijdend gemiddelde, geeft kg/week terug.
    /// Het gemiddelde dempt korte pieken (ziekte/vocht) zodat die het advies niet vertekenen.
    private static func weeklyWeightChangeRate(for weights: [WeightLog]) -> Double? {
        let sorted = weights.sorted { $0.date < $1.date }
        guard !sorted.isEmpty else { return nil }

        var smoothed: [(date: Date, value: Double)] = []
        var previous = sorted[0].weightKg
        let alpha = 0.2

        for (index, log) in sorted.enumerated() {
            let value = index == 0 ? log.weightKg : alpha * log.weightKg + (1 - alpha) * previous
            previous = value
            smoothed.append((date: log.date, value: value))
        }

        guard smoothed.count >= 2, let referenceDate = smoothed.first?.date else { return nil }

        let xs = smoothed.map { $0.date.timeIntervalSince(referenceDate) / 86400 }
        let ys = smoothed.map { $0.value }

        let n = Double(xs.count)
        let sumX = xs.reduce(0, +)
        let sumY = ys.reduce(0, +)
        let sumXY = zip(xs, ys).reduce(0) { $0 + $1.0 * $1.1 }
        let sumXX = xs.reduce(0) { $0 + $1 * $1 }

        let denominator = n * sumXX - sumX * sumX
        guard denominator != 0 else { return nil }

        let slopePerDay = (n * sumXY - sumX * sumY) / denominator
        return slopePerDay * 7
    }
}

//
//  Calculators.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//
