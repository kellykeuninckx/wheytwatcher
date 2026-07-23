import SwiftUI
import SwiftData

struct ProfileView: View {

    let profile: UserProfile

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: PurchaseManager

    @State private var showingEditGoal = false
    @State private var showingDeleteConfirmation = false
    @State private var showingAddRestDay = false
    @State private var showingPaywall = false
    @State private var showingBackup = false

    @AppStorage("wwBluntCoachMode") private var bluntCoachMode = false
    @AppStorage("wwShowBodyMeasurementsChart") private var showBodyMeasurementsChart = false
    @AppStorage("wwTrainingCalorieCreditPercent") private var trainingCalorieCreditPercent: Double = 50
    @AppStorage("wwReminderEveningLog") private var reminderEveningLog = true
    @AppStorage("wwReminderWeeklyWeighIn") private var reminderWeeklyWeighIn = true
    @AppStorage("wwReminderGoalEnding") private var reminderGoalEnding = true
    @AppStorage("wwWeighInWeekday") private var weighInWeekday = 2

    private var weekdayOptions: [(value: Int, name: String)] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "nl_NL")
        return calendar.weekdaySymbols.enumerated().map { index, name in
            (value: index + 1, name: name.capitalized)
        }
    }

    var body: some View {

        NavigationStack {

            WWScreen(accent: .wwPurple) {

                ScrollView {

                    VStack(spacing: 16) {

                        headerCard

                        statsCard

                        goalCard

                        if !profile.pastGoalPeriods.isEmpty {
                            historyCard
                        }

                        restDaySection

                        settingsSection

                        premiumCard

                        backupCard

                        deleteDataSection

                    }
                    .padding(.vertical, 8)

                }

            }
            .navigationTitle("Profiel")
            .sheet(isPresented: $showingEditGoal) {
                EditGoalSheet(profile: profile)
            }
            .sheet(isPresented: $showingAddRestDay) {
                AddRestDaySheet()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingBackup) {
                BackupView(profile: profile)
            }
            .alert("Gegevens verwijderen", isPresented: $showingDeleteConfirmation) {
                Button("Nee", role: .cancel) {}
                Button("Ja, verwijder", role: .destructive) {
                    deleteProfileData()
                }
            } message: {
                Text("Deze actie kan niet ongedaan worden. Weet je zeker dat je wil doorgaan?")
            }

        }

    }

    // MARK: - Header

    private var headerCard: some View {
        HStack(spacing: 12) {

            ZStack {
                Circle()
                    .fill(Color.wwPurple.opacity(0.15))
                    .frame(width: 36, height: 36)

                Text(initials)
                    .font(.caption.bold())
                    .foregroundStyle(Color.wwPurple)
            }

            VStack(alignment: .leading, spacing: 1) {

                Text(profile.name)
                    .font(.headline)
                    .foregroundStyle(Color.wwDarkAccent)

                Text("\(profile.age) jaar • \(profile.sex.rawValue)")
                    .font(.caption)
                    .foregroundStyle(Color.wwSecondaryText)

            }

            Spacer()

        }
        .wwCard()
    }

    private var initials: String {
        let parts = profile.name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }

    // MARK: - Lichaamsgegevens

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text("Gegevens")
                .font(.headline)
                .foregroundStyle(Color.wwDarkAccent)

            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 8) {

                GridRow {
                    CalorieInfoRow(
                        icon: "ruler",
                        label: "Lengte",
                        value: "\(profile.heightCm.roundedInt) cm",
                        color: .wwBlue
                    )

                    CalorieInfoRow(
                        icon: "scalemass",
                        label: "Gewicht",
                        value: "\(profile.currentWeightKg.roundedInt) kg",
                        color: .wwTeal
                    )
                }

                GridRow {
                    CalorieInfoRow(
                        icon: "figure.run",
                        label: "Activiteit",
                        value: profile.activityLevel.rawValue,
                        color: .wwOrange
                    )

                    if let bodyFat = profile.estimatedBodyFatPercentage {
                        CalorieInfoRow(
                            icon: "percent",
                            label: "Vetpercentage",
                            value: "\(bodyFat.roundedInt)%",
                            color: .wwCoral
                        )
                    } else {
                        Color.clear
                            .frame(width: 1, height: 1)
                    }
                }

            }

            Text("Deze gegevens kun je bij een nieuw weegmoment aanpassen.")
                .font(.caption2)
                .foregroundStyle(Color.wwTertiaryText)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .wwCard()
    }

    // MARK: - Huidig doel

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("Huidig doel")
                    .font(.headline)
                    .foregroundStyle(Color.wwDarkAccent)

                Spacer()

                Button("Wijzig doel") {
                    showingEditGoal = true
                }
                .font(.subheadline.bold())
                .foregroundStyle(Color.wwTeal)
            }

            HStack(spacing: 10) {

                Text(profile.goalMode.rawValue)
                    .font(.subheadline.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.wwAqua.opacity(0.18))
                    .foregroundStyle(Color.wwTeal)
                    .clipShape(Capsule())

                Text(profile.goalPace.rawValue)
                    .font(.subheadline.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.wwOrange.opacity(0.15))
                    .foregroundStyle(Color.wwOrange)
                    .clipShape(Capsule())

            }

            if let period = profile.activeGoalPeriod {

                VStack(alignment: .leading, spacing: 6) {

                    Text("Week \(period.currentWeekNumber) van \(period.durationWeeks) • nog \(period.weeksRemaining) \(period.weeksRemaining == 1 ? "week" : "weken") te gaan")
                        .font(.subheadline)
                        .foregroundStyle(Color.wwSecondaryText)

                    ProgressView(
                        value: Double(period.currentWeekNumber),
                        total: Double(period.durationWeeks)
                    )
                    .tint(Color.wwTeal)

                }
                .padding(.top, 4)

            }

            Text(profile.goalMode.shortDescription)
                .font(.caption)
                .foregroundStyle(Color.wwTertiaryText)

        }
        .wwCard()
    }

    // MARK: - Geschiedenis

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Geschiedenis")
                .font(.headline)
                .foregroundStyle(Color.wwDarkAccent)

            ForEach(profile.pastGoalPeriods) { period in

                HStack {

                    VStack(alignment: .leading, spacing: 2) {

                        Text("\(period.goalMode.rawValue) • \(period.goalPace.rawValue)")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.wwDarkAccent)

                        Text("\(period.startDate.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, locale: Locale(identifier: "nl_NL")))) – \(period.endDate.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, locale: Locale(identifier: "nl_NL"))))")
                            .font(.caption)
                            .foregroundStyle(Color.wwSecondaryText)

                    }

                    Spacer()

                    Text("\(period.durationWeeks)w")
                        .font(.caption.bold())
                        .foregroundStyle(Color.wwTertiaryText)

                }
                .padding(.vertical, 4)

                if period.id != profile.pastGoalPeriods.last?.id {
                    Divider()
                }

            }

        }
        .wwCard()
    }

    // MARK: - Instellingen (lichaamsmetingen-grafiek + herinneringen)

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("Instellingen")
                .font(.headline)
                .foregroundStyle(Color.wwDarkAccent)

            VStack(alignment: .leading, spacing: 4) {

                Toggle("Bot-als-een-baksteen modus", isOn: $bluntCoachMode)
                    .tint(Color.wwTeal)
                    .foregroundStyle(Color.wwDarkAccent)

                Text("Liever een sarcastische coach met een knipoog?")
                    .font(.caption2)
                    .foregroundStyle(Color.wwTertiaryText)

            }

            Divider()

            Toggle("Toon lichaamsmetingen in Progressie", isOn: $showBodyMeasurementsChart)
                .tint(Color.wwTeal)
                .foregroundStyle(Color.wwDarkAccent)

            Divider()

            VStack(alignment: .leading, spacing: 4) {

                Stepper(
                    "Trainingscalorieën terugverdienen: \(Int(trainingCalorieCreditPercent))%",
                    value: $trainingCalorieCreditPercent,
                    in: 0...100,
                    step: 10
                )
                .tint(Color.wwTeal)
                .foregroundStyle(Color.wwDarkAccent)

                Text("Bepaalt hoeveel van je geschatte, per training verbrande calorieën we teruggeven aan je dagbudget. Schattingen vallen vaak hoger uit dan de werkelijkheid — een lager percentage houdt je dichter bij je beoogde tekort of overschot.")
                    .font(.caption2)
                    .foregroundStyle(Color.wwTertiaryText)

            }

            Divider()

            Text("Herinneringen")
                .font(.subheadline.bold())
                .foregroundStyle(Color.wwDarkAccent)

            Toggle("Nog niet gelogd (18:00)", isOn: $reminderEveningLog)
                .tint(Color.wwTeal)
                .foregroundStyle(Color.wwDarkAccent)
                .onChange(of: reminderEveningLog) {
                    ReminderManager.setEveningLogReminderEnabled(reminderEveningLog)
                }

            Toggle("Wekelijkse gewicht-herinnering", isOn: $reminderWeeklyWeighIn)
                .tint(Color.wwTeal)
                .foregroundStyle(Color.wwDarkAccent)
                .onChange(of: reminderWeeklyWeighIn) {
                    ReminderManager.setWeeklyWeighInReminderEnabled(reminderWeeklyWeighIn, weekday: weighInWeekday)
                }

            if reminderWeeklyWeighIn {
                Picker("Wegdag", selection: $weighInWeekday) {
                    ForEach(weekdayOptions, id: \.value) { option in
                        Text(option.name).tag(option.value)
                    }
                }
                .tint(Color.wwTeal)
                .foregroundStyle(Color.wwDarkAccent)
                .onChange(of: weighInWeekday) {
                    ReminderManager.setWeeklyWeighInReminderEnabled(reminderWeeklyWeighIn, weekday: weighInWeekday)
                }
            }

            Toggle("Doelperiode loopt bijna af", isOn: $reminderGoalEnding)
                .tint(Color.wwTeal)
                .foregroundStyle(Color.wwDarkAccent)
                .onChange(of: reminderGoalEnding) {
                    ReminderManager.setGoalEndingReminderEnabled(reminderGoalEnding, period: profile.activeGoalPeriod)
                }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .wwCard()
    }

    // MARK: - Rustdag toevoegen

    private var restDaySection: some View {
        VStack(alignment: .leading, spacing: 6) {

            Button {
                showingAddRestDay = true
            } label: {
                Label("Rustdag toevoegen", systemImage: "bed.double.fill")
                    .font(.subheadline.bold())
            }
            .tint(Color.wwTeal)

            Text("Ben je ziek, met vakantie of toe aan een rustdag? Vink deze optie dan aan.")
                .font(.caption2)
                .foregroundStyle(Color.wwTertiaryText)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .wwCard()
    }

    // MARK: - Premium

    private var premiumCard: some View {
        VStack(alignment: .leading, spacing: 6) {

            if purchaseManager.isPremiumUnlocked {

                Label("Premium ontgrendeld", systemImage: "star.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.wwOrange)

                Text("Bedankt voor je steun — alle premium-functies staan open.")
                    .font(.caption2)
                    .foregroundStyle(Color.wwTertiaryText)

            } else {

                Button {
                    showingPaywall = true
                } label: {
                    Label("Ontgrendel Premium", systemImage: "star.fill")
                        .font(.subheadline.bold())
                }
                .tint(Color.wwOrange)

                Text("Eenmalige aankoop — geen abonnement.")
                    .font(.caption2)
                    .foregroundStyle(Color.wwTertiaryText)

            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .wwCard()
    }

    // MARK: - Back-up

    private var backupCard: some View {
        VStack(alignment: .leading, spacing: 6) {

            Button {
                showingBackup = true
            } label: {
                Label("Back-up & herstel", systemImage: "square.and.arrow.up.on.square")
                    .font(.subheadline.bold())
            }
            .tint(Color.wwTeal)

            Text("Bewaar al je gegevens in één bestand, of zet een eerdere back-up terug.")
                .font(.caption2)
                .foregroundStyle(Color.wwTertiaryText)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .wwCard()
    }

    // MARK: - Gegevens verwijderen

    private var deleteDataSection: some View {
        VStack(alignment: .leading, spacing: 6) {

            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label("Gegevens verwijderen", systemImage: "trash")
                    .font(.subheadline.bold())
            }
            .tint(Color.wwCoral)

            Text("Verwijdert je profiel en doelgeschiedenis en start de onboarding opnieuw. Geen zorgen: je logboek, gewicht, favorieten, trainingen en opgeslagen maaltijden blijven bewaard.")
                .font(.caption2)
                .foregroundStyle(Color.wwTertiaryText)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .wwCard()
    }

    private func deleteProfileData() {
        modelContext.delete(profile)
        try? modelContext.save()
        dismiss()
    }

}

// MARK: - Doel wijzigen

struct EditGoalSheet: View {

    let profile: UserProfile
    var completionMessage: String? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var goalMode: GoalMode
    @State private var goalPace: GoalPace
    @State private var durationWeeks: Int
    @State private var showingDurationInfo = false

    init(profile: UserProfile, completionMessage: String? = nil) {
        self.profile = profile
        self.completionMessage = completionMessage
        _goalMode = State(initialValue: profile.goalMode)
        _goalPace = State(initialValue: profile.goalPace)
        _durationWeeks = State(
            initialValue: profile.activeGoalPeriod?.durationWeeks
                ?? GoalDurationAdvisor.recommendedWeeks(for: profile.goalMode, pace: profile.goalPace)
        )
    }

    var body: some View {

        NavigationStack {

            Form {

                if let completionMessage {
                    Section {
                        Text(completionMessage)
                            .font(.subheadline)
                            .foregroundStyle(Color.wwDarkAccent)
                    }
                }

                Section("Doel") {

                    Picker("Doel", selection: $goalMode) {
                        ForEach(GoalMode.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }

                    Picker("Tempo", selection: $goalPace) {
                        ForEach(GoalPace.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }

                    Stepper(
                        "Duur: \(durationWeeks) weken",
                        value: $durationWeeks,
                        in: 2...52
                    )

                    HStack(spacing: 6) {

                        Text("Advies: \(GoalDurationAdvisor.recommendedWeeks(for: goalMode, pace: goalPace)) weken")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button {
                            showingDurationInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(.plain)

                    }
                    .popover(isPresented: $showingDurationInfo) {
                        Text(GoalDurationAdvisor.adviceText(for: goalMode, pace: goalPace))
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                            .frame(width: 280)
                            .presentationCompactAdaptation(.popover)
                    }

                }

                Section {
                    Button {
                        profile.startNewGoalPeriod(
                            mode: goalMode,
                            pace: goalPace,
                            durationWeeks: durationWeeks
                        )
                        try? modelContext.save()
                        dismiss()
                    } label: {
                        Text("Bevestig nieuw doel")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.wwTeal)
                }

            }
            .navigationTitle(completionMessage == nil ? "Doel wijzigen" : "Nieuw doel kiezen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") {
                        dismiss()
                    }
                }
            }
            .onChange(of: goalMode) {
                durationWeeks = GoalDurationAdvisor.recommendedWeeks(for: goalMode, pace: goalPace)
            }
            .onChange(of: goalPace) {
                durationWeeks = GoalDurationAdvisor.recommendedWeeks(for: goalMode, pace: goalPace)
            }

        }

    }

}

//
//  ProfileView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 07/07/2026.
//

// MARK: - Rustdag/ziek/vakantie toevoegen

struct AddRestDaySheet: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var existingDayStatuses: [DayStatus]

    @State private var type: DayStatusType = .restDay
    @State private var startDate: Date = Date()
    @State private var useEndDate = false
    @State private var endDate: Date = Date()

    var body: some View {

        NavigationStack {

            ZStack {

                DumbbellPatternBackground()

                Form {

                    Section("Type") {
                        Picker("Type", selection: $type) {
                            ForEach(DayStatusType.allCases) { option in
                                Label(option.rawValue, systemImage: option.icon).tag(option)
                            }
                        }
                    }
                    .listRowBackground(Color.wwCardBackground)

                    Section("Periode") {

                        DatePicker("Vanaf", selection: $startDate, displayedComponents: .date)
                            .foregroundStyle(Color.wwDarkAccent)

                        Toggle("Tot een einddatum", isOn: $useEndDate.animation())
                            .tint(Color.wwTeal)
                            .foregroundStyle(Color.wwDarkAccent)

                        if useEndDate {
                            DatePicker(
                                "Tot en met",
                                selection: $endDate,
                                in: startDate...,
                                displayedComponents: .date
                            )
                            .foregroundStyle(Color.wwDarkAccent)
                        }

                    }
                    .listRowBackground(Color.wwCardBackground)

                    Section {
                        Text("Handig voor vakantie, waar je de einddatum vaak al weet. Bij ziekte kun je 'm gewoon later nog verlengen via het Logboek.")
                            .font(.caption)
                            .foregroundStyle(Color.wwSecondaryText)
                    }
                    .listRowBackground(Color.wwCardBackground)

                }
                .scrollContentBackground(.hidden)

            }
            .tint(Color.wwTeal)
            .navigationTitle("Rustdag toevoegen")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Bewaar") {
                        save()
                    }
                }
            }

        }

    }

    private func save() {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: startDate)
        let end = useEndDate ? calendar.startOfDay(for: endDate) : start

        var day = start
        while day <= end {

            if let existing = existingDayStatuses.first(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
                modelContext.delete(existing)
            }

            let status = DayStatus(date: day, type: type)
            modelContext.insert(status)

            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = nextDay

        }

        try? modelContext.save()
        dismiss()
    }

}
