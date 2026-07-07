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
            List {
                
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dayTitle)
                            .font(.headline)
                        
                        Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                if groupedMeals.isEmpty {
                    
                    ContentUnavailableView(
                        "Geen maaltijden gevonden",
                        systemImage: "fork.knife",
                        description: Text("Er zijn geen maaltijden gelogd op deze datum.")
                    )
                    
                } else {
                    
                    Section("Maaltijden") {
                        
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
                                    
                                    Spacer()
                                    
                                    Text("(\(meal.1.count))")
                                        .foregroundStyle(.secondary)
                                    
                                }
                                .padding(.vertical, 6)
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                Section {
                    
                    Button {
                        showingDatePicker.toggle()
                    } label: {
                        Label("Andere datum", systemImage: "calendar")
                    }
                    
                }
                
            }
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
                    VStack {
                        DatePicker(
                            "Datum",
                            selection: $selectedDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding()
                        
                        Spacer()
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
    
    private var dayTitle: String {
        if Calendar.current.isDateInYesterday(selectedDate) {
            return "Gisteren"
        } else {
            return selectedDate.formatted(.dateTime.weekday(.wide))
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
    @State private var selectedEntries: Set<FoodLogEntry>

    init(meal: MealCategory, entries: [FoodLogEntry], onFinished: @escaping () -> Void) {
        self.meal = meal
        self.entries = entries
        self.onFinished = onFinished
        _selectedEntries = State(initialValue: Set(entries))
    }

    var body: some View {
        List {
            ForEach(entries) { entry in
                Button {
                    toggle(entry)
                } label: {
                    HStack(spacing: 12) {

                        Image(systemName: selectedEntries.contains(entry) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedEntries.contains(entry) ? Color.wwTeal : Color.secondary)

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
            }
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

#Preview {
    CopyMealsView()
}
