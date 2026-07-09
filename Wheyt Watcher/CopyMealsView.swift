import SwiftUI
import SwiftData

struct CopyMealsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Query private var foodEntries: [FoodLogEntry]
    
    @State private var selectedDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    @State private var showingDatePicker = false
    
    private var sourceEntries: [FoodLogEntry] {
        foodEntries.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
    
    private var groupedMeals: [(MealCategory, [FoodLogEntry])] {
        MealCategory.allCases.compactMap { category in
            let items = sourceEntries.filter { $0.mealCategory == category }
            return items.isEmpty ? nil : (category, items)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {

                DumbbellPatternBackground()

                List {

                    dateNavigator
                        .cardRow()

                    if groupedMeals.isEmpty {

                        WWPlaceholderCard(
                            icon: "fork.knife",
                            color: .wwOrange,
                            title: "Geen maaltijden gevonden",
                            message: "Er zijn geen maaltijden gelogd op deze datum."
                        )
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)

                    } else {

                        Text("Maaltijden")
                            .font(.caption.bold())
                            .foregroundStyle(Color.wwSecondaryText)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 2, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)

                        ForEach(groupedMeals, id: \.0) { meal in

                            NavigationLink {

                                CopyMealDetailView(
                                    meal: meal.0,
                                    entries: meal.1,
                                    onFinished: { dismiss() }
                                )

                            } label: {

                                HStack {

                                    Text(meal.0.rawValue)
                                        .font(.headline)
                                        .foregroundStyle(Color.wwDarkAccent)

                                    Spacer()

                                    Text("(\(meal.1.count))")
                                        .foregroundStyle(Color.wwSecondaryText)

                                }

                            }
                            .cardRow()

                        }

                    }

                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

            }
            .tint(Color.wwOrange)
            .navigationTitle("Kopieer maaltijd")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                NavigationStack {
                    ZStack {

                        DumbbellPatternBackground()

                        VStack {
                            DatePicker(
                                "Datum",
                                selection: $selectedDate,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .tint(Color.wwOrange)
                            .padding()
                            .background(Color.wwCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .padding()

                            Spacer()
                        }

                    }
                    .navigationTitle("Kies datum")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Gereed") {
                                showingDatePicker = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    private var dayTitle: String {
        if isToday {
            return "Vandaag"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            return "Gisteren"
        } else {
            return selectedDate.formatted(.dateTime.weekday(.wide))
        }
    }

    private var dateNavigator: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.wwTeal)
                    .padding(4)
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 0) {
                Text(dayTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.wwDarkAccent)

                Text(selectedDate, format: .dateTime.day().month(.wide))
                    .font(.caption)
                    .foregroundStyle(Color.wwDarkAccent.opacity(0.5))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showingDatePicker = true
            }

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3.bold())
                    .foregroundStyle(isToday ? Color.wwDarkAccent.opacity(0.2) : Color.wwTeal)
                    .padding(4)
            }
            .buttonStyle(.plain)
            .disabled(isToday)
        }
    }
    
    private func icon(for category: MealCategory) -> String {
        switch category {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "apple.logo"
        case .preWorkout: return "bolt.fill"
        case .postWorkout: return "figure.strengthtraining.traditional"
        case .other: return "fork.knife"
        }
    }
}

// MARK: - Losse producten selecteren voor het kopiëren

struct CopyMealDetailView: View {

    let meal: MealCategory
    let entries: [FoodLogEntry]
    let onFinished: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var selectedEntries: Set<FoodLogEntry> = []

    init(meal: MealCategory, entries: [FoodLogEntry], onFinished: @escaping () -> Void) {
        self.meal = meal
        self.entries = entries
        self.onFinished = onFinished
    }

    var body: some View {
        ZStack {

            DumbbellPatternBackground()

            List {
                ForEach(entries) { entry in
                    Button {
                        toggle(entry)
                    } label: {
                        HStack(spacing: 12) {

                            Image(systemName: selectedEntries.contains(entry) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedEntries.contains(entry) ? Color.wwTeal : Color.wwSecondaryText)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.name)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Color.wwDarkAccent)

                                Text("\(entry.grams.roundedInt) g • \(entry.calories.roundedInt) kcal")
                                    .font(.caption)
                                    .foregroundStyle(Color.wwSecondaryText)
                            }

                            Spacer()

                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .cardRow()
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)

        }
        .navigationTitle(meal.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button {
                copySelected()
            } label: {
                Text("Kopieer \(selectedEntries.count) product\(selectedEntries.count == 1 ? "" : "en")")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.wwOrange)
            .disabled(selectedEntries.isEmpty)
            .padding()
            .background(.thinMaterial)
        }
    }

    private func toggle(_ entry: FoodLogEntry) {
        if selectedEntries.contains(entry) {
            selectedEntries.remove(entry)
        } else {
            selectedEntries.insert(entry)
        }
    }

    private func copySelected() {
        for item in entries where selectedEntries.contains(item) {

            let newEntry = FoodLogEntry(
                date: Date(),
                mealCategory: item.mealCategory,
                name: item.name,
                grams: item.grams,
                calories: item.calories,
                proteinGrams: item.proteinGrams,
                carbsGrams: item.carbsGrams,
                fatGrams: item.fatGrams,
                fiberGrams: item.fiberGrams,
                note: item.note
            )

            modelContext.insert(newEntry)

        }

        try? modelContext.save()

        onFinished()
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

#Preview {
    CopyMealsView()
}
