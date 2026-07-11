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
        BadgeTier(threshold: 1000, name: "Eerste Hap", message: "Je eerste kilo kwark zit erop. De reis begint."),
        BadgeTier(threshold: 2500, name: "Kwark Liefhebber", message: "2,5 kg kwark — ongeveer een grote zak bloem."),
        BadgeTier(threshold: 5000, name: "Kwark Beginner", message: "5 kg kwark — ongeveer het gewicht van een kleine wasbeer."),
        BadgeTier(threshold: 10000, name: "Kwark Doorzetter", message: "10 kg kwark — ongeveer het gewicht van een peuter."),
        BadgeTier(threshold: 15000, name: "Kwark Kenner", message: "15 kg kwark — je zou er een flinke boodschappentas mee vullen."),
        BadgeTier(threshold: 30000, name: "Kwark Fanaat", message: "30 kg kwark — ongeveer het gewicht van een grote hond."),
        BadgeTier(threshold: 60000, name: "Kwark Kampioen", message: "60 kg kwark — zo ongeveer het gewicht van een dwerggeit."),
        BadgeTier(threshold: 100000, name: "Kwark Koning", message: "100 kg kwark. Dat is ongeveer je eigen lichaamsgewicht aan kwark, opgegeten.")
    ]

    static let streak: [BadgeTier] = [
        BadgeTier(threshold: 7, name: "Week Vol", message: "7 dagen op rij gelogd. Mooie gewoonte in wording."),
        BadgeTier(threshold: 14, name: "Twee Weken Sterk", message: "14 dagen op rij gelogd. Je bent duidelijk niet toevallig begonnen."),
        BadgeTier(threshold: 30, name: "Maand Meester", message: "30 dagen op rij — dat is geen toeval meer, dat is discipline."),
        BadgeTier(threshold: 50, name: "Halve Eeuw", message: "50 dagen op rij — halverwege naar de honderd."),
        BadgeTier(threshold: 75, name: "Bijna Legendarisch", message: "75 dagen op rij. Nog een kwart te gaan tot de honderd."),
        BadgeTier(threshold: 100, name: "Eeuwenaar", message: "100 dagen op rij gelogd. Dat is bijna een kwart jaar consistentie.")
    ]

    static let walking: [BadgeTier] = [
        BadgeTier(threshold: 10, name: "Wandelaar", message: "10 uur gewandeld — een mooi begin."),
        BadgeTier(threshold: 25, name: "Flinke Wandelaar", message: "25 uur gewandeld, ongeveer Den Haag naar Rotterdam, een paar keer over."),
        BadgeTier(threshold: 50, name: "Wandelheld", message: "50 uur gewandeld — dat is Scheveningen naar Noordwijk én terug, meerdere keren."),
        BadgeTier(threshold: 100, name: "Wandellegende", message: "100 uur gewandeld. Serieus indrukwekkend.")
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
