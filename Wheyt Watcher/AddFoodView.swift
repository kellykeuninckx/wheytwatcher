import SwiftUI
import SwiftData

struct AddFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var mealCategory: MealCategory = .breakfast
    @State private var grams = 100.0
    @State private var caloriesPer100g = 0.0
    @State private var proteinPer100g = 0.0
    @State private var carbsPer100g = 0.0
    @State private var fatPer100g = 0.0
    @State private var fiberPer100g = 0.0
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Product") {
                    TextField("Naam", text: $name)

                    Picker("Moment", selection: $mealCategory) {
                        ForEach(MealCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }

                    HStack {
                        Text("Hoeveelheid")
                        Spacer()
                        TextField("gram", value: $grams, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                    }
                }

                Section("Per 100 gram") {
                    numberField("Calorieën", value: $caloriesPer100g, unit: "kcal")
                    numberField("Eiwit", value: $proteinPer100g, unit: "g")
                    numberField("Koolhydraten", value: $carbsPer100g, unit: "g")
                    numberField("Vet", value: $fatPer100g, unit: "g")
                    numberField("Vezels", value: $fiberPer100g, unit: "g")
                }

                Section("Totaal") {
                    Text("\(scaled(caloriesPer100g).roundedInt) kcal")
                    Text("\(scaled(proteinPer100g).roundedInt) g eiwit")
                    Text("\(scaled(carbsPer100g).roundedInt) g koolhydraten")
                    Text("\(scaled(fatPer100g).roundedInt) g vet")
                    Text("\(scaled(fiberPer100g).roundedInt) g vezels")
                }

                Section("Notitie optioneel") {
                    TextField("Bijv. veel zout, andere portie, uit eten", text: $note)
                }
            }
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

    private func numberField(_ title: String, value: Binding<Double>, unit: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField(title, value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
            Text(unit)
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
        dismiss()
    }
}

