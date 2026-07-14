import Foundation

struct BackupPayload: Codable {
    var exportedAt: Date
    var profile: ProfileDTO?
    var goalPeriods: [GoalPeriodDTO]
    var foodEntries: [FoodLogEntryDTO]
    var trainings: [TrainingSessionDTO]
    var weightLogs: [WeightLogDTO]
    var measurementLogs: [BodyMeasurementLogDTO]
    var dayStatuses: [DayStatusDTO]
    var snapshots: [DailyTargetSnapshotDTO]
    var favorites: [FavoriteFoodDTO]
    var savedMeals: [SavedMealDTO]
    var foodProducts: [FoodProductDTO]
    var mealTemplates: [MealTemplateDTO]
}

struct ProfileDTO: Codable {
    var name: String
    var age: Int
    var sex: String
    var heightCm: Double
    var currentWeightKg: Double
    var estimatedBodyFatPercentage: Double?
    var goalMode: String
    var goalPace: String
    var activityLevel: String
    var createdAt: Date
}

struct GoalPeriodDTO: Codable {
    var startDate: Date
    var durationWeeks: Int
    var goalMode: String
    var goalPace: String
    var isActive: Bool
    var completedAt: Date?
    var calorieAdjustment: Double
    var lastCheckInDate: Date?
}

struct FoodLogEntryDTO: Codable {
    var date: Date
    var mealCategory: String
    var name: String
    var grams: Double
    var calories: Double
    var proteinGrams: Double
    var carbsGrams: Double
    var fatGrams: Double
    var fiberGrams: Double
    var note: String?
}

struct TrainingSessionDTO: Codable {
    var date: Date
    var type: String
    var durationMinutes: Int
    var rpe: Int
    var bodyWeightKg: Double
    var estimatedCaloriesBurned: Double
    var note: String?
}

struct WeightLogDTO: Codable {
    var date: Date
    var weightKg: Double
    var note: String?
}

struct BodyMeasurementLogDTO: Codable {
    var date: Date
    var waistCm: Double?
    var chestCm: Double?
    var hipsCm: Double?
    var armCm: Double?
    var thighCm: Double?
}

struct DayStatusDTO: Codable {
    var date: Date
    var type: String
}

struct DailyTargetSnapshotDTO: Codable {
    var date: Date
    var goalMode: String
    var goalPace: String
    var calories: Double
    var proteinGrams: Double
    var carbsGrams: Double
    var fatGrams: Double
    var fiberGrams: Double
    var trainingCalories: Double
}

struct FavoriteFoodDTO: Codable {
    var name: String
    var grams: Double
    var calories: Double
    var proteinGrams: Double
    var carbsGrams: Double
    var fatGrams: Double
    var fiberGrams: Double
}

struct MealItemDTO: Codable {
    var name: String
    var grams: Double
    var calories: Double
    var proteinGrams: Double
    var carbsGrams: Double
    var fatGrams: Double
    var fiberGrams: Double
}

struct SavedMealDTO: Codable {
    var name: String
    var createdAt: Date
    var items: [MealItemDTO]
}

struct FoodProductDTO: Codable {
    var name: String
    var brand: String?
    var barcode: String?
    var caloriesPer100g: Double
    var proteinPer100g: Double
    var carbsPer100g: Double
    var fatPer100g: Double
    var fiberPer100g: Double
    var createdAt: Date
}

struct MealTemplateDTO: Codable {
    var name: String
    var category: String
    var calories: Double
    var proteinGrams: Double
    var carbsGrams: Double
    var fatGrams: Double
    var fiberGrams: Double
    var createdAt: Date
}
