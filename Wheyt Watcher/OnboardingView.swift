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

    @State private var waistText = ""
    @State private var chestText = ""
    @State private var hipsText = ""
    @State private var armText = ""
    @State private var thighText = ""

    @State private var goalMode: GoalMode = .maintenance

    @State private var goalPace: GoalPace = .normal

    @State private var activityLevel: ActivityLevel = .light

    @State private var durationWeeks: Int = GoalDurationAdvisor.recommendedWeeks(for: .maintenance, pace: .normal)
    @State private var showingDurationInfo = false

    @AppStorage("wwWeighInWeekday") private var weighInWeekday = 2
    @AppStorage("wwReminderWeeklyWeighIn") private var reminderWeeklyWeighIn = true

    private var weekdayOptions: [(value: Int, name: String)] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "nl_NL")
        return calendar.weekdaySymbols.enumerated().map { index, name in
            (value: index + 1, name: name.capitalized)
        }
    }

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

                Section("Lichaamsmaten (optioneel, in cm)") {

                    HStack {
                        Text("Taille").foregroundStyle(Color.wwDarkAccent)
                        Spacer()
                        TextField("cm", text: $waistText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(Color.wwDarkAccent)
                    }

                    HStack {
                        Text("Borst").foregroundStyle(Color.wwDarkAccent)
                        Spacer()
                        TextField("cm", text: $chestText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(Color.wwDarkAccent)
                    }

                    HStack {
                        Text("Heupen").foregroundStyle(Color.wwDarkAccent)
                        Spacer()
                        TextField("cm", text: $hipsText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(Color.wwDarkAccent)
                    }

                    HStack {
                        Text("Arm").foregroundStyle(Color.wwDarkAccent)
                        Spacer()
                        TextField("cm", text: $armText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(Color.wwDarkAccent)
                    }

                    HStack {
                        Text("Dijbeen").foregroundStyle(Color.wwDarkAccent)
                        Spacer()
                        TextField("cm", text: $thighText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(Color.wwDarkAccent)
                    }

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

                Section("Wekelijkse weeg-herinnering") {

                    Picker("Wegdag", selection: $weighInWeekday) {
                        ForEach(weekdayOptions, id: \.value) { option in
                            Text(option.name).tag(option.value)
                        }
                    }
                    .foregroundStyle(Color.wwDarkAccent)

                    Text("Dagelijks wegen kan natuurlijk ook — dit is puur een wekelijkse herinnering, geen limiet.")
                        .font(.caption2)
                        .foregroundStyle(Color.wwSecondaryText)

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

        let measurementLog = BodyMeasurementLog(
            date: Date(),
            waistCm: Double(waistText.replacingOccurrences(of: ",", with: ".")),
            chestCm: Double(chestText.replacingOccurrences(of: ",", with: ".")),
            hipsCm: Double(hipsText.replacingOccurrences(of: ",", with: ".")),
            armCm: Double(armText.replacingOccurrences(of: ",", with: ".")),
            thighCm: Double(thighText.replacingOccurrences(of: ",", with: "."))
        )

        if measurementLog.hasAnyValue {
            modelContext.insert(measurementLog)
        }

        ReminderManager.setWeeklyWeighInReminderEnabled(reminderWeeklyWeighIn, weekday: weighInWeekday)

    }

}
//  OnboardingView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//
