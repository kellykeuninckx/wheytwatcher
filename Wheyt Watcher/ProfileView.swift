import SwiftUI
import SwiftData

struct ProfileView: View {

    let profile: UserProfile

    @Environment(\.modelContext) private var modelContext

    @State private var showingEditGoal = false

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

                    }
                    .padding(.vertical, 8)

                }

            }
            .navigationTitle("Profiel")
            .sheet(isPresented: $showingEditGoal) {
                EditGoalSheet(profile: profile)
            }

        }

    }

    // MARK: - Header

    private var headerCard: some View {
        HStack(spacing: 14) {

            ZStack {
                Circle()
                    .fill(Color.wwPurple.opacity(0.15))
                    .frame(width: 44, height: 44)

                Text(initials)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.wwPurple)
            }

            VStack(alignment: .leading, spacing: 2) {

                Text(profile.name)
                    .font(.title3.bold())
                    .foregroundStyle(Color.wwDarkAccent)

                Text("\(profile.age) jaar • \(profile.sex.rawValue)")
                    .font(.subheadline)
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
        VStack(alignment: .leading, spacing: 14) {

            Text("Gegevens")
                .font(.headline)
                .foregroundStyle(Color.wwDarkAccent)

            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 14) {

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

                        Text("\(period.startDate.formatted(date: .abbreviated, time: .omitted)) – \(period.endDate.formatted(date: .abbreviated, time: .omitted))")
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
