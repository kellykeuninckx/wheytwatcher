import SwiftUI
import SwiftData

struct AddWeightView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let profile: UserProfile

    @State private var weightKg: Double

    init(profile: UserProfile) {
        self.profile = profile
        _weightKg = State(initialValue: profile.currentWeightKg)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Gewicht") {
                    HStack {
                        Text("Vandaag")
                        Spacer()
                        TextField("kg", value: $weightKg, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("kg")
                    }
                }
            }
            .navigationTitle("Gewicht loggen")
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
        profile.currentWeightKg = weightKg

        let log = WeightLog(date: Date(), weightKg: weightKg)
        modelContext.insert(log)

        dismiss()
    }
}
//
//  AddWeightView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//

