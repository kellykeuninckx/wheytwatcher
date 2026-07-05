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

    var body: some View {

        NavigationStack {

            Form {

                Section("Jij") {

                    TextField(
                        "Naam",
                        text: $name
                    )

                    Stepper(
                        "Leeftijd: \(age)",
                        value: $age,
                        in: 12...90
                    )

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

                        Spacer()

                        TextField(
                            "cm",
                            value: $heightCm,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)

                        Text("cm")

                    }

                    HStack {

                        Text("Gewicht")

                        Spacer()

                        TextField(
                            "kg",
                            value: $weightKg,
                            format: .number
                        )
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)

                        Text("kg")

                    }

                    TextField(
                        "Vetpercentage (optioneel)",
                        text: $bodyFatText
                    )
                    .keyboardType(.decimalPad)

                }

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

                }

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

                }

            }
            .navigationTitle("Profiel")
            .navigationBarTitleDisplayMode(.inline)

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

    }

}
//  OnboardingView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//

