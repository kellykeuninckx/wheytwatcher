import Foundation

struct BadgeTier: Identifiable, Equatable {
    let id = UUID()
    let threshold: Double
    let name: String
    let message: String

    static func == (lhs: BadgeTier, rhs: BadgeTier) -> Bool {
        lhs.name == rhs.name
    }
}

/// Drie prestatie-categorieën — bewust beperkt gehouden, geen losse badge per willekeurige actie.
enum BadgeTiers {

    static let kwark: [BadgeTier] = [
        BadgeTier(threshold: 1000, name: "Eerste hap", message: "Dat was je eerste kilo. Je kwarkreis begint nu."),
        BadgeTier(threshold: 2500, name: "Kwark liefhebber", message: "2,5kg kwark is ongeveer 4 basketballen. Probeer die eens tegelijk in je handen te houden ;-)"),
        BadgeTier(threshold: 5000, name: "Kwark beginneling", message: "5kg kwark – dat zijn zo'n 25 vinyl platen van je favoriete artiest."),
        BadgeTier(threshold: 10000, name: "Kwark doorzetter", message: "10kg kwark – inmiddels heb je een kleine peuter op. Nou ja, 't gewicht ervan dan."),
        BadgeTier(threshold: 15000, name: "Kwark kenner", message: "15kg kwark... Til eens een kettlebel van dat gewicht op, dan weet je pas hoeveel het is."),
        BadgeTier(threshold: 30000, name: "Kwark fanaat", message: "30kg kwark is het gewicht van meer dan 11.000 pingpongballetjes. Ga zo door."),
        BadgeTier(threshold: 60000, name: "Kwark kampioen", message: "60kg kwark. Dat zijn meer dan 19.000 theezakjes. Dat is één kopje per dag, 52 jaar lang!"),
        BadgeTier(threshold: 100000, name: "Kwark koning", message: "100kg kwark. Je bent de onbetwiste kwark koning. Gefeliciteerd!")
    ]

    static let streak: [BadgeTier] = [
        BadgeTier(threshold: 7, name: "7 dagen streak", message: "7 dagen op rij gelogd. Dat is een mooie gewoonte in wording."),
        BadgeTier(threshold: 14, name: "14 dagen streak", message: "14 dagen al! Dat is duidelijk geen toeval meer."),
        BadgeTier(threshold: 30, name: "30 dagen streak", message: "30 dagen… Een hele maand gelogd. Dat noem je nou discipline."),
        BadgeTier(threshold: 50, name: "50 dagen streak", message: "50 dagen op rij – dat is halverwege de 100. Zet 'm op!"),
        BadgeTier(threshold: 75, name: "75 dagen streak", message: "75 dagen. Bijna bijna de 100, nu niet stoppen!"),
        BadgeTier(threshold: 100, name: "100 dagen streak", message: "100 dagen op rij gelogd. Dat mag gevierd worden!")
    ]

    static let walking: [BadgeTier] = [
        BadgeTier(threshold: 10, name: "Wandelaar", message: "10 uur gewandeld. Dat is een mooi begin."),
        BadgeTier(threshold: 15, name: "Vlotte wandelaar", message: "15 uur gewandeld. Dat is ongeveer van Amsterdam naar Rotterdam."),
        BadgeTier(threshold: 30, name: "Wandelheld", message: "30 uur gewandeld. Dat is ongeveer van Amsterdam naar Antwerpen."),
        BadgeTier(threshold: 50, name: "Wandelfanaat", message: "50 uur gewandeld. Dat is ongeveer als van Groningen naar Maastricht lopen — bijna het hele land door."),
        BadgeTier(threshold: 75, name: "Wandellegende", message: "75 uur gewandeld. Dat is ongeveer als van Amsterdam naar Parijs lopen."),
        BadgeTier(threshold: 100, name: "Wandelkoning", message: "100 uur gewandeld. Wauw, dat is serieus indrukwekkend.")
    ]

    static func current(value: Double, tiers: [BadgeTier]) -> BadgeTier? {
        tiers.last { value >= $0.threshold }
    }

    static func next(value: Double, tiers: [BadgeTier]) -> BadgeTier? {
        tiers.first { value < $0.threshold }
    }

}

/// Berekent de ruwe waardes waarop de tiers hierboven zijn gebaseerd — apart van de UI,
/// zodat TodayView (voor de "nieuwe badge"-popup) en ProgressView (voor de kaart) exact
/// dezelfde regels gebruiken.
enum BadgeMetrics {

    static func totalKwarkGrams(foodEntries: [FoodLogEntry]) -> Double {
        foodEntries
            .filter { $0.name.localizedCaseInsensitiveContains("kwark") }
            .reduce(0) { $0 + $1.grams }
    }

    static func longestLoggingStreak(foodEntries: [FoodLogEntry], dayStatuses: [DayStatus]) -> Int {
        let calendar = Calendar.current
        let loggedDays = Set(foodEntries.map { calendar.startOfDay(for: $0.date) })
        let marked = Set(dayStatuses.map { calendar.startOfDay(for: $0.date) })

        guard let firstDay = loggedDays.min() else { return 0 }

        var day = firstDay
        var current = 0
        var longest = 0
        let today = calendar.startOfDay(for: Date())

        while day <= today {
            if loggedDays.contains(day) {
                current += 1
                longest = max(longest, current)
            } else if !marked.contains(day) {
                current = 0
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }

        return longest
    }

    static func totalWalkingHours(trainings: [TrainingSession]) -> Double {
        let totalMinutes = trainings
            .filter { $0.type == .walking }
            .reduce(0) { $0 + $1.durationMinutes }
        return Double(totalMinutes) / 60.0
    }

}
