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
        content.title = "Nog niet gelogd vandaag"
        content.body = "Een paar minuutjes is genoeg om je dag compleet te maken."
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

    /// `weekday` volgt Calendar's conventie: 1 = zondag, 2 = maandag, ... 7 = zaterdag.
    static func setWeeklyWeighInReminderEnabled(_ enabled: Bool, weekday: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [weeklyWeighInIdentifier])

        guard enabled else { return }

        requestAuthorizationIfNeeded()

        let content = UNMutableNotificationContent()
        content.title = "Tijd om te wegen"
        content.body = "Een wekelijkse meting geeft het beste beeld van je trend."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = weekday
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: weeklyWeighInIdentifier, content: content, trigger: trigger)
        center.add(request)
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
        content.title = "Je doelperiode loopt bijna af"
        content.body = "Nog 3 dagen te gaan. Tijd om na te denken over je volgende stap."
        content.sound = .default

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: reminderDate)
        dateComponents.hour = 10
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: goalEndingIdentifier, content: content, trigger: trigger)
        center.add(request)
    }

}//
//  ReminderManager.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 09/07/2026.
//

