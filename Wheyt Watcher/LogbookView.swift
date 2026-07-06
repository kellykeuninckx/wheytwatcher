import SwiftUI
import SwiftData

struct MealsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Maaltijden",
                systemImage: "fork.knife",
                description: Text("Hier komen je herhaalmaaltijden. Dit bouwen we als volgende stap.")
            )
            .navigationTitle("Maaltijden")
        }
    }
}

struct LogbookView: View {
    @Query private var foodEntries: [FoodLogEntry]
    @Query private var trainings: [TrainingSession]

    var body: some View {
        NavigationStack {
            List {
                Section("Eten") {
                    ForEach(foodEntries.sorted { $0.date > $1.date }) { entry in
                        VStack(alignment: .leading) {
                            Text(entry.name)
                                .font(.headline)
                            Text("\(entry.calories.roundedInt) kcal - \(entry.grams.roundedInt) g")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
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
}

struct ProgressViewScreen: View {
    @Query private var weightLogs: [WeightLog]

    private var sortedWeights: [WeightLog] {
        weightLogs.sorted { $0.date > $1.date }
    }

    private var latestWeight: Double? {
        sortedWeights.first?.weightKg
    }

    private var sevenDayAverage: Double? {
        let recent = sortedWeights.prefix(7)
        guard !recent.isEmpty else { return nil }
        return recent.reduce(0) { $0 + $1.weightKg } / Double(recent.count)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Gewicht") {
                    if let latestWeight {
                        HStack {
                            Text("Laatste gewicht")
                            Spacer()
                            Text("\(latestWeight, specifier: "%.1f") kg")
                        }
                    }

                    if let sevenDayAverage {
                        HStack {
                            Text("7-daags gemiddelde")
                            Spacer()
                            Text("\(sevenDayAverage, specifier: "%.1f") kg")
                        }
                    }
                }

                Section("Logs") {
                    ForEach(sortedWeights) { log in
                        HStack {
                            Text(log.date, style: .date)
                            Spacer()
                            Text("\(log.weightKg, specifier: "%.1f") kg")
                        }
                    }
                }
            }
            .navigationTitle("Progressie")
        }
    }
}
//
//  PlaceholderViews.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//

