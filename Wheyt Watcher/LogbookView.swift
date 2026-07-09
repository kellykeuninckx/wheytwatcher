import SwiftUI
import SwiftData

struct LogbookView: View {

    @Query private var foodEntries: [FoodLogEntry]
    @Query private var trainings: [TrainingSession]
    @Query private var favorites: [FavoriteFood]
    @Query private var dayStatuses: [DayStatus]

    @Environment(\.modelContext) private var modelContext

    @State private var isSelecting = false
    @State private var showingSaveMeal = false
    @State private var selectedEntries: Set<FoodLogEntry> = []

    private enum LogFilter: String, CaseIterable, Identifiable {
        case all = "Alles"
        case food = "Voeding"
        case training = "Training"
        var id: String { rawValue }
    }

    @State private var selectedFilter: LogFilter = .all

    private var showsFood: Bool {
        selectedFilter != .training
    }

    private var showsTraining: Bool {
        selectedFilter != .food
    }

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

                    filterRow

                    if showsFood {

                        ForEach(sortedDays, id: \.self) { day in

                            let dayEntries = groupedEntries[day] ?? []

                            dayLabelRow(for: day)

                            ForEach(MealCategory.allCases, id: \.self) { meal in

                                let mealEntries = dayEntries.filter {
                                    $0.mealCategory == meal
                                }

                                if !mealEntries.isEmpty {

                                    mealLabelRow(meal)

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
                                        .cardRow()

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

                    if showsTraining {

                        trainingLabelRow

                        ForEach(sortedTrainings) { training in

                            VStack(alignment: .leading, spacing: 2) {

                                Text(training.type.rawValue)
                                    .font(.headline)
                                    .foregroundStyle(Color.wwDarkAccent)

                                Text("\(training.durationMinutes) min • RPE \(training.rpe) • \(training.estimatedCaloriesBurned.roundedInt) kcal")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.wwSecondaryText)

                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .cardRow()

                        }
                        .onDelete { indexSet in

                            for index in indexSet {
                                modelContext.delete(sortedTrainings[index])
                            }

                            try? modelContext.save()

                        }

                    }

                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

            }
            .navigationTitle("Logboek")
            .tint(Color.wwAqua)
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

    // MARK: - Filter

    private var filterRow: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(LogFilter.allCases) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 4)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    // MARK: - Label-rijen (bewust gewone rijen i.p.v. Section-headers, zodat de kleur altijd klopt)

    private func mealLabelRow(_ meal: MealCategory) -> some View {
        Text(meal.rawValue)
            .font(.caption.bold())
            .foregroundStyle(Color.wwTeal)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 2, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }

    private var trainingLabelRow: some View {
        Text("Training")
            .font(.subheadline.bold())
            .foregroundStyle(Color.wwDarkAccent)
            .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 4, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }

    // MARK: - Dagstatus (ziek / vakantie / rustdag)

    private func status(for day: Date) -> DayStatus? {
        dayStatuses.first { Calendar.current.isDate($0.date, inSameDayAs: day) }
    }

    private func setStatus(_ type: DayStatusType?, for day: Date) {
        if let existing = status(for: day) {
            modelContext.delete(existing)
        }

        if let type {
            let newStatus = DayStatus(date: day, type: type)
            modelContext.insert(newStatus)
        }

        try? modelContext.save()
    }

    private func dayLabelRow(for day: Date) -> some View {
        let currentStatus = status(for: day)

        return HStack(spacing: 6) {

            Text(day.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, locale: Locale(identifier: "nl_NL"))))
                .font(.subheadline.bold())
                .foregroundStyle(Color.wwDarkAccent)

            if let currentStatus {
                HStack(spacing: 3) {
                    Image(systemName: currentStatus.type.icon)
                    Text(currentStatus.type.rawValue)
                }
                .font(.caption2.bold())
                .foregroundStyle(Color.wwOrange)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.wwOrange.opacity(0.15))
                .clipShape(Capsule())
            }

            Spacer()

            Menu {

                ForEach(DayStatusType.allCases) { type in
                    Button {
                        setStatus(type, for: day)
                    } label: {
                        Label(type.rawValue, systemImage: type.icon)
                    }
                }

                if currentStatus != nil {
                    Divider()
                    Button("Normaal (verwijder markering)", role: .destructive) {
                        setStatus(nil, for: day)
                    }
                }

            } label: {
                Image(systemName: "bed.double.fill")
                    .foregroundStyle(Color.wwSecondaryText)
            }

        }
        .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 4, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
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

// MARK: - Kaart-stijl voor losse rijen in een List (Favorieten-achtige zwevende kaart)

private extension View {
    func cardRow() -> some View {
        self
            .padding(14)
            .background(Color.wwCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}
