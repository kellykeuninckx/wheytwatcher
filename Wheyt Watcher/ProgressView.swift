import SwiftUI
import SwiftData


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
        
//  ProgressView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 06/07/2026.
//

