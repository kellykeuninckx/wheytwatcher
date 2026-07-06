import SwiftUI
import SwiftData

struct LogbookView: View {

    @Query private var foodEntries: [FoodLogEntry]
    @Query private var trainings: [TrainingSession]
    @Query private var favorites: [FavoriteFood]

    @Environment(\.modelContext) private var modelContext

    @State private var isSelecting = false
    @State private var selectedEntries: Set<FoodLogEntry> = []

    private var groupedEntries: [Date: [FoodLogEntry]] {
        Dictionary(grouping: foodEntries) {
            Calendar.current.startOfDay(for: $0.date)
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

                            let mealEntries = dayEntries.filter {
                                $0.mealCategory == meal
                            }

                            if !mealEntries.isEmpty {

                                Section(meal.rawValue) {

                                    ForEach(mealEntries) { entry in

                                        LogbookEntryRow(
                                            entry: entry,
                                            isFavorite: isFavorite(entry),

                                            isSelecting: isSelecting,
                                            isSelected: selectedEntries.contains(entry),

                                            toggleFavorite: {
                                                toggleFavorite(entry)
                                            },

                                            toggleSelection: {

                                                if selectedEntries.contains(entry) {

                                                    selectedEntries.remove(entry)

                                                } else {

                                                    selectedEntries.insert(entry)

                                                }

                                            }
                                        )

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

                    ForEach(trainings.sorted(by: { $0.date > $1.date })) { training in

                        VStack(alignment: .leading) {

                            Text(training.type.rawValue)
                                .font(.headline)

                            Text("\(training.durationMinutes) min • RPE \(training.rpe) • \(training.estimatedCaloriesBurned.roundedInt) kcal")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                        }

                    }
                    .onDelete { indexSet in

                        let sorted = trainings.sorted {
                            $0.date > $1.date
                        }

                        for index in indexSet {

                            modelContext.delete(sorted[index])

                        }

                        try? modelContext.save()

                    }

                }

            }
            .navigationTitle("Logboek")
            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {

                    Button(isSelecting ? "Gereed" : "Selecteer") {

                        isSelecting.toggle()

                        if !isSelecting {

                            selectedEntries.removeAll()

                        }

                    }

                }

            }

        }

    }

    private func isFavorite(_ entry: FoodLogEntry) -> Bool {

        favorites.contains {
            $0.name == entry.name
        }

    }

    private func toggleFavorite(_ entry: FoodLogEntry) {

        if let existing = favorites.first(where: { $0.name == entry.name }) {

            modelContext.delete(existing)

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

    }

}
