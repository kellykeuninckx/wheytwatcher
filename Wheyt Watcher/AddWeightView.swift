import SwiftUI
import SwiftData

struct AddWeightView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let profile: UserProfile

    @State private var weightKg: Double
    @State private var bodyFatText: String
    @State private var activityLevel: ActivityLevel

    init(profile: UserProfile) {
        self.profile = profile
        _weightKg = State(initialValue: profile.currentWeightKg)
        _bodyFatText = State(
            initialValue: profile.estimatedBodyFatPercentage.map { String($0) } ?? ""
        )
        _activityLevel = State(initialValue: profile.activityLevel)
    }

    var body: some View {
        NavigationStack {
            ZStack {

                DumbbellPatternBackground()

                Form {
                    Section("Gewicht") {
                        HStack {
                            Text("Vandaag")
                                .foregroundStyle(Color.wwDarkAccent)
                            Spacer()
                            TextField("kg", value: $weightKg, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(Color.wwDarkAccent)
                            Text("kg")
                                .foregroundStyle(Color.wwSecondaryText)
                        }
                    }
                    .listRowBackground(Color.wwCardBackground)

                    Section("Vetpercentage (optioneel)") {
                        HStack {
                            TextField("bv. 18", text: $bodyFatText)
                                .keyboardType(.decimalPad)
                                .foregroundStyle(Color.wwDarkAccent)
                            Text("%")
                                .foregroundStyle(Color.wwSecondaryText)
                        }
                    }
                    .listRowBackground(Color.wwCardBackground)

                    Section("Activiteit") {
                        Picker("Activiteit", selection: $activityLevel) {
                            ForEach(ActivityLevel.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    }
                    .listRowBackground(Color.wwCardBackground)
                }
                .scrollContentBackground(.hidden)

            }
            .tint(Color.wwTeal)
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
        profile.activityLevel = activityLevel

        if let bodyFat = Double(bodyFatText.replacingOccurrences(of: ",", with: ".")) {
            profile.estimatedBodyFatPercentage = bodyFat
        }

        let log = WeightLog(date: Date(), weightKg: weightKg)
        modelContext.insert(log)

        try? modelContext.save()

        dismiss()
    }
}
//
//  AddWeightView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//
