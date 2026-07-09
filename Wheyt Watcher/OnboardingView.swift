import SwiftUI
import SwiftData

struct OnboardingView: View {

    @Environment(\.modelContext) private var modelContext

    @State private var name = ""

    @State private var age = 30

    @State private var sex: Sex = .male

    @State private var heightCm = 180.0

    @State private var weightKg = 80.0

    @State private var bodyFatText = ""

    @State private var goalMode: GoalMode = .maintenance

    @State private var goalPace: GoalPace = .normal

    @State private var activityLevel: ActivityLevel = .light

    @State private var durationWeeks: Int = GoalDurationAdvisor.recommendedWeeks(for: .maintenance, pace: .normal)
    @State private var showingDurationInfo = false

    var body: some View {

        NavigationStack {

            ZStack {

                DumbbellPatternBackground()

                Form {

                Section("Jij") {

                    TextField(
                        "Naam",
                        text: $name
                    )
                    .foregroundStyle(Color.wwDarkAccent)

                    Stepper(
                        "Leeftijd: \(age)",
                        value: $age,
                        in: 12...90
                    )
                    .foregroundStyle(Color.wwDarkAccent)

                    Picker(
                        "Geslacht",
                        selection: $sex
                    ) {

                        ForEach(Sex.allCases) { option in

                            Text(option.rawValue)
                                .tag(option)

                        }

                    }

                    HStack {

                        Text("Lengte")
                            .foregroundStyle(Color.wwDarkAccent)

                        Spacer()

                        TextField(
                            "cm",
                            value: $heightCm,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(Color.wwDarkAccent)

                        Text("cm")
                            .foregroundStyle(Color.wwSecondaryText)

                    }

                    HStack {

                        Text("Gewicht")
                            .foregroundStyle(Color.wwDarkAccent)

                        Spacer()

                        TextField(
                            "kg",
                            value: $weightKg,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(Color.wwDarkAccent)

                        Text("kg")
                            .foregroundStyle(Color.wwSecondaryText)

                    }

                    TextField(
                        "Vetpercentage (optioneel)",
                        text: $bodyFatText
                    )
                    .keyboardType(.decimalPad)
                    .foregroundStyle(Color.wwDarkAccent)

                }
                .listRowBackground(Color.wwCardBackground)

                Section("Doel") {

                    Picker(
                        "Doel",
                        selection: $goalMode
                    ) {

                        ForEach(GoalMode.allCases) { option in

                            Text(option.rawValue)
                                .tag(option)

                        }

                    }

                    Picker(
                        "Tempo",
                        selection: $goalPace
                    ) {

                        ForEach(GoalPace.allCases) { option in

                            Text(option.rawValue)
                                .tag(option)

                        }

                    }

                    Picker(
                        "Activiteit",
                        selection: $activityLevel
                    ) {

                        ForEach(ActivityLevel.allCases) { option in

                            Text(option.rawValue)
                                .tag(option)

                        }

                    }

                    Stepper(
                        "Duur: \(durationWeeks) weken",
                        value: $durationWeeks,
                        in: 2...52
                    )
                    .foregroundStyle(Color.wwDarkAccent)

                    HStack(spacing: 6) {

                        Text("Advies: \(GoalDurationAdvisor.recommendedWeeks(for: goalMode, pace: goalPace)) weken")
                            .font(.caption)
                            .foregroundStyle(Color.wwSecondaryText)

                        Spacer()

                        Button {
                            showingDurationInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(Color.wwTeal)

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
                .listRowBackground(Color.wwCardBackground)

                Section {

                    Button {

                        saveProfile()

                    } label: {

                        Text("Start Wheyt Watcher")
                            .frame(maxWidth: .infinity)

                    }
                    .disabled(
                        name
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                    )
                    .buttonStyle(.borderedProminent)
                    .tint(Color.wwTeal)

                } footer: {

                    Text("Tip: Ziek, op vakantie of toe aan een rustdag? Dat kun je instellen via je Profiel of op je Vandaag scherm. Zo tellen deze dagen niet mee als 'gemist'. Handig!")
                        .font(.caption2)
                        .foregroundStyle(Color.wwSecondaryText)

                }
                .listRowBackground(Color.wwCardBackground)

                }
                .scrollContentBackground(.hidden)

            }
            .tint(Color.wwTeal)
            .navigationTitle("Profiel")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: goalMode) {
                durationWeeks = GoalDurationAdvisor.recommendedWeeks(for: goalMode, pace: goalPace)
            }
            .onChange(of: goalPace) {
                durationWeeks = GoalDurationAdvisor.recommendedWeeks(for: goalMode, pace: goalPace)
            }

        }

    }

    private func saveProfile() {

        let bodyFat = Double(
            bodyFatText
                .replacingOccurrences(
                    of: ",",
                    with: "."
                )
        )

        let profile = UserProfile(

            name: name,

            age: age,

            sex: sex,

            heightCm: heightCm,

            currentWeightKg: weightKg,

            estimatedBodyFatPercentage: bodyFat,

            goalMode: goalMode,

            goalPace: goalPace,

            activityLevel: activityLevel

        )

        modelContext.insert(profile)

        let firstWeightLog = WeightLog(

            date: Date(),

            weightKg: weightKg

        )

        modelContext.insert(firstWeightLog)

        let initialGoalPeriod = GoalPeriod(
            startDate: Date(),
            durationWeeks: durationWeeks,
            goalMode: goalMode,
            goalPace: goalPace,
            isActive: true
        )
        initialGoalPeriod.profile = profile

        modelContext.insert(initialGoalPeriod)

    }

}
//  OnboardingView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//
