import SwiftUI
import SwiftData

struct AddTrainingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let profile: UserProfile

    @State private var type: TrainingType = .hyrox
    @State private var durationMinutes = 60
    @State private var rpe = 8

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
            Form {
                Section("Training") {
                    Picker("Type", selection: $type) {
                        ForEach(TrainingType.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }

                    Stepper("Duur: \(durationMinutes) min", value: $durationMinutes, in: 5...240, step: 5)
                    Stepper("RPE: \(rpe)/10", value: $rpe, in: 1...10)
                }

                Section("Schatting") {
                    Text("\(estimatedCalories.roundedInt) kcal verbrand")
                    Text("Deze schatting gebruikt type training, duur, RPE en lichaamsgewicht.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
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
        dismiss()
    }
}
//
//  AddTrainingView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//

