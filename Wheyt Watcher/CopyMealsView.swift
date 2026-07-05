
import SwiftUI
import SwiftData

struct CopyMealsView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

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

                        Text(selectedDate.formatted(date: .complete, time: .omitted))
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

                            Button {

                                // TODO: Kopieerlogica

                            } label: {

                                HStack {

                                    Image(systemName: icon(for: meal.0))
                                        .foregroundStyle(Color.wwTeal)
                                        .frame(width: 24)

                                    Text(meal.0.rawValue)

                                    Spacer()

                                    Text("(\(meal.1.count))")
                                        .foregroundStyle(.secondary)

                                    Image(systemName: "chevron.right")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)

                                }
                                .padding(.vertical, 6)

                            }
                            .buttonStyle(.plain)

                        }

                    }

                }

                Section {

                    Button {
                        showingDatePicker.toggle()
                    } label: {
                        Label("Kies andere datum", systemImage: "calendar")
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

#Preview {
    CopyMealsView()
}

//
//  CopyMealsView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//

