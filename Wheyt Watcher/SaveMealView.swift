import SwiftUI
import SwiftData

struct SaveMealView: View {

    let entries: [FoodLogEntry]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var mealName = ""

    var body: some View {

        NavigationStack {

            Form {

                Section("Naam") {

                    TextField("Bijvoorbeeld: Enchiladas", text: $mealName)

                }

            }
            .navigationTitle("Maaltijd opslaan")

            .toolbar {

                ToolbarItem(placement: .topBarLeading) {

                    Button("Annuleren") {
                        dismiss()
                    }

                }

                ToolbarItem(placement: .topBarTrailing) {

                    Button("Opslaan") {

                        let meal = SavedMeal(name: mealName)
                        for entry in entries {

                            let item = MealItem(
                                name: entry.name,
                                grams: entry.grams,
                                calories: entry.calories,
                                proteinGrams: entry.proteinGrams,
                                carbsGrams: entry.carbsGrams,
                                fatGrams: entry.fatGrams,
                                fiberGrams: entry.fiberGrams
                            )

                            meal.items.append(item)

                        }

                        modelContext.insert(meal)

                        try? modelContext.save()

                        dismiss()

                    }
                    .disabled(mealName.trimmingCharacters(in: .whitespaces).isEmpty)

                }

            }

        }

    }

}//
//  SavedMealView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 06/07/2026.
//

