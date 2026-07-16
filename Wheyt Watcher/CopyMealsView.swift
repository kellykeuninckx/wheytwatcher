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
            return selectedDate.formatted(Date.FormatStyle(locale: Locale(identifier: "nl_NL")).weekday(.wide))
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

    private struct CopySelection {
        var isSelected: Bool = false
        var gramsText: String
        var category: MealCategory
    }

    @State private var selections: [CopySelection]

    init(meal: MealCategory, entries: [FoodLogEntry], onFinished: @escaping () -> Void) {
        self.meal = meal
        self.entries = entries
        self.onFinished = onFinished
        _selections = State(initialValue: entries.map {
            CopySelection(isSelected: false, gramsText: String($0.grams.roundedInt), category: $0.mealCategory)
        })
    }

    private var selectedCount: Int {
        selections.filter { $0.isSelected }.count
    }

    var body: some View {
        ZStack {

            DumbbellPatternBackground()

            List {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in

                    VStack(alignment: .leading, spacing: 10) {

                        Button {
                            selections[index].isSelected.toggle()
                        } label: {
                            HStack(spacing: 12) {

                                Image(systemName: selections[index].isSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selections[index].isSelected ? Color.wwTeal : Color.wwSecondaryText)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.name)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(Color.wwDarkAccent)

                                    Text("origineel: \(entry.grams.roundedInt) g • \(entry.calories.roundedInt) kcal")
                                        .font(.caption2)
                                        .foregroundStyle(Color.wwTertiaryText)
                                }

                                Spacer()

                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if selections[index].isSelected {

                            HStack(spacing: 16) {

                                HStack(spacing: 6) {
                                    Text("Gram")
                                        .font(.caption)
                                        .foregroundStyle(Color.wwSecondaryText)

                                    TextField("gram", text: $selections[index].gramsText)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 56)
                                        .foregroundStyle(Color.wwDarkAccent)
                                }

                                Spacer()

                                Menu {
                                    ForEach(MealCategory.allCases) { category in
                                        Button(category.rawValue) {
                                            selections[index].category = category
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(selections[index].category.rawValue)
                                        Image(systemName: "chevron.down")
                                    }
                                    .font(.caption.bold())
                                    .foregroundStyle(Color.wwOrange)
                                }

                            }
                            .padding(.leading, 32)

                        }

                    }
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
                Text("Kopieer \(selectedCount) product\(selectedCount == 1 ? "" : "en")")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.wwOrange)
            .disabled(selectedCount == 0)
            .padding()
            .background(.thinMaterial)
        }
    }

    private func copySelected() {
        for (index, entry) in entries.enumerated() where selections[index].isSelected {

            let selection = selections[index]
            let newGrams = Double(selection.gramsText.replacingOccurrences(of: ",", with: ".")) ?? entry.grams
            let ratio = entry.grams > 0 ? newGrams / entry.grams : 1

            let newEntry = FoodLogEntry(
                date: Date(),
                mealCategory: selection.category,
                name: entry.name,
                grams: newGrams,
                calories: entry.calories * ratio,
                proteinGrams: entry.proteinGrams * ratio,
                carbsGrams: entry.carbsGrams * ratio,
                fatGrams: entry.fatGrams * ratio,
                fiberGrams: entry.fiberGrams * ratio,
                note: entry.note
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
