import SwiftUI
import SwiftData

struct AddFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var prefilledBarcode: String? = nil

    @State private var name = ""
    @State private var mealCategory: MealCategory = .breakfast
    @State private var gramsText = "100"
    @State private var caloriesPer100gText = ""
    @State private var proteinPer100gText = ""
    @State private var carbsPer100gText = ""
    @State private var fatPer100gText = ""
    @State private var fiberPer100gText = ""
    @State private var note = ""

    private var grams: Double {
        Double(gramsText.replacingOccurrences(of: ",", with: ".")) ?? 100
    }
    private var caloriesPer100g: Double {
        Double(caloriesPer100gText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    private var proteinPer100g: Double {
        Double(proteinPer100gText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    private var carbsPer100g: Double {
        Double(carbsPer100gText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    private var fatPer100g: Double {
        Double(fatPer100gText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }
    private var fiberPer100g: Double {
        Double(fiberPer100gText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    var body: some View {
        NavigationStack {
            ZStack {

                DumbbellPatternBackground()

                Form {
                    Section("Product") {
                        TextField("Naam", text: $name)
                            .foregroundStyle(Color.wwDarkAccent)

                        Picker("Moment", selection: $mealCategory) {
                            ForEach(MealCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }

                        HStack {
                            Text("Hoeveelheid")
                                .foregroundStyle(Color.wwDarkAccent)
                            Spacer()
                            SelectAllTextField(
                                text: $gramsText,
                                placeholder: "gram",
                                keyboardType: .decimalPad,
                                textColor: UIColor(Color.wwDarkAccent)
                            )
                            .frame(width: 70)
                            Text("g")
                                .foregroundStyle(Color.wwSecondaryText)
                        }

                        if prefilledBarcode != nil {
                            Text("Wordt gekoppeld aan deze barcode, zodat je 'm de volgende keer meteen kan scannen.")
                                .font(.caption)
                                .foregroundStyle(Color.wwSecondaryText)
                        }
                    }
                    .listRowBackground(Color.wwCardBackground)

                    Section("Per 100 gram") {
                        numberField("Calorieën", text: $caloriesPer100gText, unit: "kcal")
                        numberField("Eiwit", text: $proteinPer100gText, unit: "g")
                        numberField("Koolhydraten", text: $carbsPer100gText, unit: "g")
                        numberField("Vet", text: $fatPer100gText, unit: "g")
                        numberField("Vezels", text: $fiberPer100gText, unit: "g")
                    }
                    .listRowBackground(Color.wwCardBackground)

                    Section("Totaal") {
                        Text("\(scaled(caloriesPer100g).roundedInt) kcal")
                        Text("\(scaled(proteinPer100g).roundedInt) g eiwit")
                        Text("\(scaled(carbsPer100g).roundedInt) g koolhydraten")
                        Text("\(scaled(fatPer100g).roundedInt) g vet")
                        Text("\(scaled(fiberPer100g).roundedInt) g vezels")
                    }
                    .foregroundStyle(Color.wwDarkAccent)
                    .listRowBackground(Color.wwCardBackground)

                    Section("Notitie optioneel") {
                        TextField("Bijv. veel zout, andere portie, uit eten", text: $note)
                            .foregroundStyle(Color.wwDarkAccent)
                    }
                    .listRowBackground(Color.wwCardBackground)
                }
                .scrollContentBackground(.hidden)

            }
            .tint(Color.wwTeal)
            .navigationTitle("Eten toevoegen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Voeg toe") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func numberField(_ title: String, text: Binding<String>, unit: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.wwDarkAccent)
            Spacer()
            SelectAllTextField(
                text: text,
                placeholder: title,
                keyboardType: .decimalPad,
                textColor: UIColor(Color.wwDarkAccent)
            )
            .frame(width: 70)
            Text(unit)
                .foregroundStyle(Color.wwSecondaryText)
        }
    }

    private func scaled(_ value: Double) -> Double {
        value * grams / 100.0
    }

    private func save() {
        let cleanNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        let entry = FoodLogEntry(
            date: Date(),
            mealCategory: mealCategory,
            name: name,
            grams: grams,
            calories: scaled(caloriesPer100g),
            proteinGrams: scaled(proteinPer100g),
            carbsGrams: scaled(carbsPer100g),
            fatGrams: scaled(fatPer100g),
            fiberGrams: scaled(fiberPer100g),
            note: cleanNote.isEmpty ? nil : cleanNote
        )

        modelContext.insert(entry)

        if let barcode = prefilledBarcode {
            let product = FoodProduct(
                name: name,
                barcode: barcode,
                caloriesPer100g: caloriesPer100g,
                proteinPer100g: proteinPer100g,
                carbsPer100g: carbsPer100g,
                fatPer100g: fatPer100g,
                fiberPer100g: fiberPer100g
            )
            modelContext.insert(product)
        }

        try? modelContext.save()

        dismiss()
    }
}
