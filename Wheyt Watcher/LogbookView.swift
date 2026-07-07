import SwiftUI
import SwiftData

struct LogbookView: View {

    @Query private var foodEntries: [FoodLogEntry]
    @Query private var trainings: [TrainingSession]
    @Query private var favorites: [FavoriteFood]

    @Environment(\.modelContext) private var modelContext

    @State private var isSelecting = false
    @State private var showingSaveMeal = false
    @State private var selectedEntries: Set<FoodLogEntry> = []

    private var groupedEntries: [Date: [FoodLogEntry]] {
        Dictionary(grouping: foodEntries) {
            Calendar.current.startOfDay(for: $0.date)
        }
    }

    private var sortedDays: [Date] {
        groupedEntries.keys.sorted(by: >)
    }

    private var sortedTrainings: [TrainingSession] {
        trainings.sorted { $0.date > $1.date }
    }

    var body: some View {

        NavigationStack {

            ZStack {

                DumbbellPatternBackground()

                List {

                    ForEach(sortedDays, id: \.self) { day in

                        Section {

                            let dayEntries = groupedEntries[day] ?? []

                            ForEach(MealCategory.allCases, id: \.self) { meal in

                                let mealEntries = dayEntries.filter {
                                    $0.mealCategory == meal
                                }

                                if !mealEntries.isEmpty {

                                    Section {

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
                                            .listRowBackground(Color.wwCardBackground)

                                        }
                                        .onDelete { indexSet in

                                            for index in indexSet {
                                                modelContext.delete(mealEntries[index])
                                            }

                                            try? modelContext.save()

                                        }

                                    } header: {
                                        Text(meal.rawValue)
                                            .font(.caption.bold())
                                            .foregroundStyle(Color.wwSecondaryText)
                                    }

                                }

                            }

                        } header: {
                            Text(day.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline.bold())
                                .foregroundStyle(Color.wwDarkAccent)
                        }

                    }

                    Section {

                        ForEach(sortedTrainings) { training in

                            VStack(alignment: .leading, spacing: 2) {

                                Text(training.type.rawValue)
                                    .font(.headline)
                                    .foregroundStyle(Color.wwDarkAccent)

                                Text("\(training.durationMinutes) min • RPE \(training.rpe) • \(training.estimatedCaloriesBurned.roundedInt) kcal")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.wwSecondaryText)

                            }
                            .listRowBackground(Color.wwCardBackground)

                        }
                        .onDelete { indexSet in

                            for index in indexSet {
                                modelContext.delete(sortedTrainings[index])
                            }

                            try? modelContext.save()

                        }

                    } header: {
                        Text("Training")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.wwDarkAccent)
                    }

                }
                .scrollContentBackground(.hidden)
                .listRowSeparatorTint(Color.wwDarkAccent.opacity(0.15))

            }
            .navigationTitle("Logboek")
            .tint(Color.wwTeal)
            .safeAreaInset(edge: .bottom) {

                if isSelecting && !selectedEntries.isEmpty {

                    VStack(spacing: 12) {

                        Text("\(selectedEntries.count) product\(selectedEntries.count == 1 ? "" : "en") geselecteerd")
                            .font(.subheadline.bold())
                            .foregroundStyle(Color.wwDarkAccent)

                        Button {
                            showingSaveMeal = true
                        } label: {
                            Label("Bewaar als maaltijd", systemImage: "square.and.arrow.down.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.wwOrange)

                    }
                    .padding()
                    .background(Color.wwCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                }

            }
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
            .sheet(isPresented: $showingSaveMeal) {
                SaveMealView(
                    entries: Array(selectedEntries)
                )
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
