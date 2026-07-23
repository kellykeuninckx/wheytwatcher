import SwiftUI
import SwiftData

struct AddWeightView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \BodyMeasurementLog.date, order: .reverse) private var measurementLogs: [BodyMeasurementLog]

    let profile: UserProfile

    @State private var weightKg: Double
    @State private var bodyFatText: String
    @State private var activityLevel: ActivityLevel

    @State private var waistText: String = ""
    @State private var chestText: String = ""
    @State private var hipsText: String = ""
    @State private var armText: String = ""
    @State private var thighText: String = ""

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

                    Section("Lichaamsmetingen (optioneel, in cm)") {

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
            .onAppear {
                prefillFromLastMeasurement()
            }
        }
    }

    private func prefillFromLastMeasurement() {
        guard let last = measurementLogs.first else { return }
        if waistText.isEmpty, let value = last.waistCm { waistText = String(value) }
        if chestText.isEmpty, let value = last.chestCm { chestText = String(value) }
        if hipsText.isEmpty, let value = last.hipsCm { hipsText = String(value) }
        if armText.isEmpty, let value = last.armCm { armText = String(value) }
        if thighText.isEmpty, let value = last.thighCm { thighText = String(value) }
    }

    private func save() {
        profile.currentWeightKg = weightKg
        profile.activityLevel = activityLevel

        if let bodyFat = Double(bodyFatText.replacingOccurrences(of: ",", with: ".")) {
            profile.estimatedBodyFatPercentage = bodyFat
        }

        let log = WeightLog(date: Date(), weightKg: weightKg)
        modelContext.insert(log)

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
