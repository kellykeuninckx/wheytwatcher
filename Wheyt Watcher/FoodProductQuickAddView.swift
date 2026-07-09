import SwiftUI
import SwiftData

struct FoodProductQuickAddView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let product: FoodProduct
    var onLogged: (() -> Void)? = nil

    @State private var grams: Double = 100
    @State private var meal: MealCategory = .breakfast

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
                            TextField("Gram", value: $grams, format: .number)
                                .keyboardType(.decimalPad)
                                .foregroundStyle(Color.wwDarkAccent)

                            Text("g")
                                .foregroundStyle(Color.wwSecondaryText)
                        }

                    }
                    .listRowBackground(Color.wwCardBackground)

                    Section("Maaltijd") {

                        Picker("Maaltijd", selection: $meal) {
                            ForEach(MealCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }

                    }
                    .listRowBackground(Color.wwCardBackground)

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
            .navigationTitle("Toevoegen")
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

