import SwiftUI
import SwiftData

struct FoodProductQuickAddView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let product: FoodProduct

    /// Als gezet werkt het scherm in "ingrediënt-modus": de maaltijd-keuze
    /// vervalt en in plaats van een `FoodLogEntry` te loggen wordt [onAdd]
    /// aangeroepen met het product en de gekozen hoeveelheid. Zo hergebruikt
    /// het bewerken van een opgeslagen maaltijd dezelfde flow.
    var onAdd: ((FoodProduct, Double) -> Void)? = nil
    var onLogged: (() -> Void)? = nil

    @State private var gramsText: String = "100"
    @State private var meal: MealCategory = .breakfast

    private var grams: Double {
        Double(gramsText.replacingOccurrences(of: ",", with: ".")) ?? 100
    }

    private var factor: Double {
        grams / 100.0
    }

    var body: some View {

        NavigationStack {

            ZStack {

                DumbbellPatternBackground()

                Form {

                    Section("Product") {

                        Text(product.name)
                            .foregroundStyle(Color.wwDarkAccent)

                        if let brand = product.brand, !brand.isEmpty {
                            Text(brand)
                                .font(.caption)
                                .foregroundStyle(Color.wwSecondaryText)
                        }

                    }
                    .listRowBackground(Color.wwCardBackground)

                    Section("Hoeveelheid") {

                        HStack {
                            SelectAllTextField(
                                text: $gramsText,
                                keyboardType: .decimalPad,
                                textAlignment: .left,
                                textColor: UIColor(Color.wwDarkAccent)
                            )

                            Text("g")
                                .foregroundStyle(Color.wwSecondaryText)
                        }

                    }
                    .listRowBackground(Color.wwCardBackground)

                    if onAdd == nil {

                        Section("Maaltijd") {

                            Picker("Maaltijd", selection: $meal) {
                                ForEach(MealCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue).tag(category)
                                }
                            }

                        }
                        .listRowBackground(Color.wwCardBackground)

                    }

                    Section {

                        HStack {
                            Text("Calorieën")
                                .foregroundStyle(Color.wwDarkAccent)
                            Spacer()
                            Text("\((product.caloriesPer100g * factor).roundedInt) kcal")
                                .foregroundStyle(Color.wwSecondaryText)
                        }

                    }
                    .listRowBackground(Color.wwCardBackground)

                }
                .scrollContentBackground(.hidden)

            }
            .tint(Color.wwOrange)
            .navigationTitle(onAdd != nil ? "Ingrediënt toevoegen" : "Toevoegen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Toevoegen") {
                        log()
                    }
                }

            }

        }

    }

    private func log() {

        if let onAdd {
            onAdd(product, grams)
            dismiss()
            onLogged?()
            return
        }

        let entry = FoodLogEntry(
            date: Date(),
            mealCategory: meal,
            name: product.name,
            grams: grams,
            calories: product.caloriesPer100g * factor,
            proteinGrams: product.proteinPer100g * factor,
            carbsGrams: product.carbsPer100g * factor,
            fatGrams: product.fatPer100g * factor,
            fiberGrams: product.fiberPer100g * factor
        )

        modelContext.insert(entry)
        try? modelContext.save()

        dismiss()
        onLogged?()
    }

}//
//  FoodProductQuickAddView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 08/07/2026.
//

