import SwiftUI
import SwiftData

struct AddTrainingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var trainings: [TrainingSession]

    let profile: UserProfile

    @State private var type: TrainingType = .hyrox
    @State private var durationMinutes = 60
    @State private var rpe = 8

    /// Meest gelogde types bovenaan — geen aparte instelling nodig, past zich vanzelf aan
    /// naarmate iemands trainingsgewoontes veranderen.
    private var sortedTypes: [TrainingType] {
        let counts = Dictionary(grouping: trainings, by: { $0.type }).mapValues { $0.count }
        let allCases = TrainingType.allCases

        return allCases.sorted { a, b in
            let countA = counts[a] ?? 0
            let countB = counts[b] ?? 0
            if countA != countB {
                return countA > countB
            }
            return (allCases.firstIndex(of: a) ?? 0) < (allCases.firstIndex(of: b) ?? 0)
        }
    }

    private var estimatedCalories: Double {
        TrainingCalculator.estimateCalories(
            type: type,
            durationMinutes: durationMinutes,
            rpe: rpe,
            bodyWeightKg: profile.currentWeightKg
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {

                DumbbellPatternBackground()

                Form {
                    Section("Training") {

                        Picker("Type", selection: $type) {
                            ForEach(sortedTypes) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }

                        Stepper("Duur: \(durationMinutes) min", value: $durationMinutes, in: 5...240, step: 5)
                            .foregroundStyle(Color.wwDarkAccent)

                        Stepper("RPE: \(rpe)/10", value: $rpe, in: 1...10)
                            .foregroundStyle(Color.wwDarkAccent)

                    }
                    .listRowBackground(Color.wwCardBackground)

                    Section("Schatting") {

                        Text("\(estimatedCalories.roundedInt) kcal verbrand")
                            .foregroundStyle(Color.wwDarkAccent)

                        Text("Deze schatting gebruikt type training, duur, RPE en lichaamsgewicht.")
                            .font(.footnote)
                            .foregroundStyle(Color.wwSecondaryText)

                    }
                    .listRowBackground(Color.wwCardBackground)

                }
                .scrollContentBackground(.hidden)

            }
            .tint(Color.wwTeal)
            .navigationTitle("Training loggen")
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
        let session = TrainingSession(
            date: Date(),
            type: type,
            durationMinutes: durationMinutes,
            rpe: rpe,
            bodyWeightKg: profile.currentWeightKg,
            estimatedCaloriesBurned: estimatedCalories
        )

        modelContext.insert(session)

        try? modelContext.save()

        dismiss()
    }
}
//
//  AddTrainingView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//
