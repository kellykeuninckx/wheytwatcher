import SwiftUI
import SwiftData

struct FavoriteQuickAddView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let favorite: FavoriteFood

    @State private var grams: Double
    @State private var meal: MealCategory = .breakfast

    init(favorite: FavoriteFood) {
        self.favorite = favorite
        _grams = State(initialValue: favorite.grams)
    }

    var body: some View {

        NavigationStack {

            ZStack {

                DumbbellPatternBackground()

                Form {

                    Section("Product") {

                        Text(favorite.name)
                            .foregroundStyle(Color.wwDarkAccent)

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

                            ForEach(MealCategory.allCases, id: \.self) { meal in

                                Text(meal.rawValue)
                                    .tag(meal)

                            }

                        }
                        .tint(Color.wwDarkAccent)

                    }
                    .listRowBackground(Color.wwCardBackground)

                }
                .scrollContentBackground(.hidden)

            }
            .tint(Color.wwCoral)
            .navigationTitle("Toevoegen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .confirmationAction) {

                    Button("Toevoegen") {

                        let factor = grams / favorite.grams

                        let entry = FoodLogEntry(
                            date: Date(),
                            mealCategory: meal,
                            name: favorite.name,
                            grams: grams,
                            calories: favorite.calories * factor,
                            proteinGrams: favorite.proteinGrams * factor,
                            carbsGrams: favorite.carbsGrams * factor,
                            fatGrams: favorite.fatGrams * factor,
                            fiberGrams: favorite.fiberGrams * factor
                        )
                        modelContext.insert(entry)

                        try? modelContext.save()

                        dismiss()

                    }

                }

            }

        }

    }

}
//  FavoriteQuickAddView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 06/07/2026.
//
