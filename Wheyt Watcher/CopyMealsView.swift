import SwiftUI
import SwiftData

struct CopyMealsView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var foodEntries: [FoodLogEntry]

    enum CopySource: String, CaseIterable, Identifiable {
        case yesterday = "Gisteren"
        case lastWeek = "Vorige week"
        case custom = "Andere datum"

        var id: String { rawValue }
    }

    @State private var selectedSource: CopySource = .yesterday

    @State private var selectedDate = Date()
    private var sourceDate: Date {

        let calendar = Calendar.current

        switch selectedSource {

        case .yesterday:
            return calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()

        case .lastWeek:
            return calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()

        case .custom:
            return selectedDate

        }

    }

    private var sourceEntries: [FoodLogEntry] {

        foodEntries.filter {

            Calendar.current.isDate($0.date, inSameDayAs: sourceDate)

        }

    }

    var body: some View {

        NavigationStack {

            Form {

                Section("Van") {

                    Picker("Bron", selection: $selectedSource) {

                        ForEach(CopySource.allCases) { source in

                            Text(source.rawValue)
                                .tag(source)

                        }

                    }

                    if selectedSource == .custom {

                        DatePicker(
                            "Datum",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )

                    }

                }

                Section("Maaltijden") {

                    ContentUnavailableView(
                        "Nog geen maaltijden gevonden",
                        systemImage: "fork.knife",
                        description: Text("In de volgende stap vullen we dit automatisch met de maaltijdmomenten van de gekozen dag.")
                    )

                }

                Section {

                    Button {

                        // Logica volgt in stap 2

                    } label: {

                        HStack {

                            Spacer()

                            Label(
                                "Kopieer",
                                systemImage: "doc.on.doc.fill"
                            )

                            Spacer()

                        }

                    }
                    .disabled(true)

                }

            }
            .navigationTitle("Kopieer")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {

                    Button("Sluiten") {

                        dismiss()

                    }

                }

            }

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

