import Foundation
import UserNotifications

/// Regelt alle lokale meldingen. Bewust beperkt tot 3 types, elk apart aan/uit te zetten
/// via Profiel — max. 1 melding per dag, geen streak-spam.
enum ReminderManager {

    private static let eveningLogIdentifier = "wwEveningLogReminder"
    private static let weeklyWeighInIdentifier = "wwWeeklyWeighInReminder"
    private static let goalEndingIdentifier = "wwGoalEndingReminder"

    // MARK: - Toestemming

    static func requestAuthorizationIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        }
    }

    // MARK: - 1. 's Avonds nog niet gelogd

    /// Wordt aangeroepen zodra de app opent én telkens als er iets aan vandaag's log verandert.
    /// Plant een melding voor vandaag 18:00, of haalt 'm weg als er al gelogd is / de instelling uit staat.
    static func refreshEveningLogReminder(enabled: Bool, hasLoggedToday: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [eveningLogIdentifier])

        guard enabled, !hasLoggedToday else { return }

        requestAuthorizationIfNeeded()

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = 18
        dateComponents.minute = 0

        guard let triggerDate = Calendar.current.date(from: dateComponents), triggerDate > Date() else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Vandaag nog niet gelogd."
        content.body = "Vergeet niet je dag in te voeren of een rustdag in te stellen."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false
        )

        let request = UNNotificationRequest(identifier: eveningLogIdentifier, content: content, trigger: trigger)
        center.add(request)
    }

    static func setEveningLogReminderEnabled(_ enabled: Bool) {
        if enabled {
            requestAuthorizationIfNeeded()
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [eveningLogIdentifier])
        }
    }

    // MARK: - 2. Wekelijkse gewicht-herinnering

    private static let weighInVariantIndexKey = "wwWeighInVariantIndex"

    private static let weighInVariants: [String] = [
        "Een wekelijkse meting geeft het beste beeld van je trend.",
        "Elke week hetzelfde moment kiezen maakt het makkelijker om het vol te houden.",
        "Je gewicht schommelt dagelijks — de wekelijkse trend vertelt het echte verhaal."
    ]

    /// `weekday` volgt Calendar's conventie: 1 = zondag, 2 = maandag, ... 7 = zaterdag.
    /// Wordt aangeroepen bij het aan-/uitzetten van de instelling of het wijzigen van de wegdag —
    /// plant meteen een verse melding met de eerstvolgende tekst-variant.
    static func setWeeklyWeighInReminderEnabled(_ enabled: Bool, weekday: Int) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [weeklyWeighInIdentifier])

        guard enabled else { return }

        requestAuthorizationIfNeeded()
        scheduleNextWeighInReminder(weekday: weekday)
    }

    /// Wordt aangeroepen zodra de app opent. Een gewone herhalende melding toont altijd exact
    /// dezelfde tekst — door in plaats daarvan telkens een eenmalige melding te plannen (en die
    /// hier te verversen zodra de vorige al is afgevuurd/verlopen), kan de tekst wél rouleren.
    static func refreshWeeklyWeighInReminderIfNeeded(enabled: Bool, weekday: Int) {
        guard enabled else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [weeklyWeighInIdentifier])
            return
        }

        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let alreadyScheduled = requests.contains { $0.identifier == weeklyWeighInIdentifier }
            if !alreadyScheduled {
                scheduleNextWeighInReminder(weekday: weekday)
            }
        }
    }

    private static func scheduleNextWeighInReminder(weekday: Int) {
        let defaults = UserDefaults.standard
        let variantIndex = defaults.integer(forKey: weighInVariantIndexKey) % weighInVariants.count
        defaults.set((variantIndex + 1) % weighInVariants.count, forKey: weighInVariantIndexKey)

        let content = UNMutableNotificationContent()
        content.title = "Tijd om te wegen."
        content.body = weighInVariants[variantIndex]
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = weekday
        dateComponents.hour = 9
        dateComponents.minute = 0

        // repeats: false — expres eenmalig, zodat we 'm elke keer met een nieuwe tekst kunnen
        // vervangen in plaats van vast te zitten aan één herhalende tekst.
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: weeklyWeighInIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - 3. Doelperiode loopt bijna af

    /// Plant een eenmalige melding 3 dagen vóór het einde van de actieve doelperiode.
    static func setGoalEndingReminderEnabled(_ enabled: Bool, period: GoalPeriod?) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [goalEndingIdentifier])

        guard enabled, let period else { return }

        requestAuthorizationIfNeeded()

        guard let reminderDate = Calendar.current.date(byAdding: .day, value: -3, to: period.endDate),
              reminderDate > Date() else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Je doelperiode loopt bijna af."
        content.body = "Nog 3 dagen te gaan. Nog even volhouden!"
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: reminderDate)
        dateComponents.hour = 10
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: goalEndingIdentifier, content: content, trigger: trigger)
        center.add(request)
    }

}
