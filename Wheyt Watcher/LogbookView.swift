import SwiftUI
import SwiftData


struct LogbookView: View {
    @Query private var foodEntries: [FoodLogEntry]
    @Query private var trainings: [TrainingSession]
    @Query private var favorites: [FavoriteFood]
    @Environment(\.modelContext) private var modelContext

    private var groupedEntries: [Date: [FoodLogEntry]] {

        Dictionary(
            grouping: foodEntries
        ) { entry in

            Calendar.current.startOfDay(for: entry.date)

        }

    }
    
    private var sortedDays: [Date] {

        groupedEntries.keys.sorted(by: >)

    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedDays, id: \.self) { day in

                    Section(day.formatted(date: .abbreviated, time: .omitted)) {

                        let dayEntries = groupedEntries[day] ?? []

                        ForEach(MealCategory.allCases, id: \.self) { meal in

                            let mealEntries = dayEntries
                                .filter { $0.mealCategory == meal }

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

                                                if let existingFavorite = favorites.first(where: { $0.name == entry.name }) {

                                                    modelContext.delete(existingFavorite)

                                                } else {

                                                    let favorite = FavoriteFood(
                                                        name: entry.name,
                                                        grams: entry.grams,
                                                        calories: entry.calories,
                                                        proteinGrams: entry.proteinGrams,
                                                        carbsGrams: entry.carbsGrams,
                                                        fatGrams: entry.fatGrams,
                                                        fiberGrams: entry.fiberGrams
                                                    )

                                                    modelContext.insert(favorite)

                                                }

                                                try? modelContext.save()

                                            } label: {

                                                Image(systemName: isFavorite(entry) ? "heart.fill" : "heart")
                                                    .foregroundStyle(isFavorite(entry) ? Color.wwCoral : .secondary)

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
                    .onDelete { indexSet in

                        let sortedTrainings = trainings.sorted { $0.date > $1.date }

                        for index in indexSet {
                            modelContext.delete(sortedTrainings[index])
                        }

                        try? modelContext.save()

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

