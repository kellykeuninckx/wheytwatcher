import SwiftUI
import SwiftData


struct LogbookView: View {
    @Query private var foodEntries: [FoodLogEntry]
    @Query private var trainings: [TrainingSession]
    @Query private var favorites: [FavoriteFood]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                Section("Eten") {

                    ForEach(MealCategory.allCases, id: \.self) { meal in

                        let mealEntries = foodEntries
                            .filter { $0.mealCategory == meal }
                            .sorted { $0.date > $1.date }

                        if !mealEntries.isEmpty {

                            Section(meal.rawValue) {

                                ForEach(mealEntries) { entry in

                                    HStack {

                                        VStack(alignment: .leading, spacing: 2) {

                                            Text(entry.name)
                                                .font(.headline)

                                            Text("\(entry.grams.roundedInt) g • \(entry.calories.roundedInt) kcal")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)

                                        }

                                        Spacer()

                                        Button {

                                            print("Hartje ingedrukt")

                                        } label: {

                                            Image(systemName: isFavorite(entry) ? "heart.fill" : "heart")
                                                .foregroundStyle(isFavorite(entry) ? .red : .secondary)

                                        }
                                        .buttonStyle(.plain)

                                    }

                                }
                                .onDelete { indexSet in

                                    for index in indexSet {

                                        modelContext.delete(mealEntries[index])

                                    }

                                    try? modelContext.save()

                                }

                            }

                        }

                    }

                }

                Section("Training") {
                    ForEach(trainings.sorted { $0.date > $1.date }) { training in
                        VStack(alignment: .leading) {
                            Text(training.type.rawValue)
                                .font(.headline)
                            Text("\(training.durationMinutes) min - RPE \(training.rpe) - \(training.estimatedCaloriesBurned.roundedInt) kcal")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Logboek")
        }
    }
    private func isFavorite(_ entry: FoodLogEntry) -> Bool {
        favorites.contains {
            $0.name == entry.name
        }
    }
}



//
//  PlaceholderViews.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//

