import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct BackupView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let profile: UserProfile

    @Query private var foodEntries: [FoodLogEntry]
    @Query private var trainings: [TrainingSession]
    @Query private var weightLogs: [WeightLog]
    @Query private var measurementLogs: [BodyMeasurementLog]
    @Query private var dayStatuses: [DayStatus]
    @Query private var snapshots: [DailyTargetSnapshot]
    @Query private var favorites: [FavoriteFood]
    @Query private var savedMeals: [SavedMeal]
    @Query private var foodProducts: [FoodProduct]
    @Query private var mealTemplates: [MealTemplate]

    @State private var exportURL: URL?
    @State private var exportErrorMessage: String?

    @State private var showingImporter = false
    @State private var pendingImportPayload: BackupPayload?
    @State private var showingRestoreConfirmation = false
    @State private var importErrorMessage: String?
    @State private var showingRestoreSuccess = false

    var body: some View {
        NavigationStack {
            ZStack {

                DumbbellPatternBackground()

                ScrollView {
                    VStack(spacing: 16) {

                        VStack(alignment: .leading, spacing: 8) {

                            Label("Back-up maken", systemImage: "square.and.arrow.up")
                                .font(.headline)
                                .foregroundStyle(Color.wwDarkAccent)

                            Text("Zet al je gegevens (logboek, gewicht, trainingen, favorieten, etc.) in één bestand, dat je zelf kan bewaren — bijvoorbeeld via AirDrop, Bestanden, of e-mail.")
                                .font(.caption)
                                .foregroundStyle(Color.wwSecondaryText)

                            if let exportURL {
                                ShareLink(item: exportURL) {
                                    Label("Deel back-up-bestand", systemImage: "square.and.arrow.up")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Color.wwTeal)
                            } else {
                                Button {
                                    prepareExport()
                                } label: {
                                    Label("Maak back-up", systemImage: "doc.badge.plus")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Color.wwTeal)
                            }

                            if let exportErrorMessage {
                                Text(exportErrorMessage)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }

                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .wwCard()

                        VStack(alignment: .leading, spacing: 8) {

                            Label("Back-up terugzetten", systemImage: "square.and.arrow.down")
                                .font(.headline)
                                .foregroundStyle(Color.wwDarkAccent)

                            Text("Let op: dit vervangt al je huidige gegevens door de inhoud van het back-up-bestand. Dit kan niet ongedaan gemaakt worden.")
                                .font(.caption)
                                .foregroundStyle(Color.wwSecondaryText)

                            Button {
                                showingImporter = true
                            } label: {
                                Label("Kies back-up-bestand", systemImage: "folder")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(Color.wwTeal)

                            if let importErrorMessage {
                                Text(importErrorMessage)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }

                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .wwCard()

                    }
                    .padding()
                }

            }
            .tint(Color.wwTeal)
            .navigationTitle("Back-up & herstel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.json],
                onCompletion: handleImportSelection
            )
            .alert(
                "Gegevens vervangen?",
                isPresented: $showingRestoreConfirmation
            ) {
                Button("Annuleer", role: .cancel) {
                    pendingImportPayload = nil
                }
                Button("Ja, vervang alles", role: .destructive) {
                    performRestore()
                }
            } message: {
                Text("Dit verwijdert al je huidige gegevens en zet de inhoud van het gekozen back-up-bestand terug. Dit kan niet ongedaan gemaakt worden.")
            }
            .alert("Back-up teruggezet", isPresented: $showingRestoreSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Je gegevens zijn hersteld vanuit het back-up-bestand.")
            }
        }
    }

    private func prepareExport() {
        exportErrorMessage = nil

        let payload = BackupManager.buildPayload(
            profile: profile,
            foodEntries: foodEntries,
            trainings: trainings,
            weightLogs: weightLogs,
            measurementLogs: measurementLogs,
            dayStatuses: dayStatuses,
            snapshots: snapshots,
            favorites: favorites,
            savedMeals: savedMeals,
            foodProducts: foodProducts,
            mealTemplates: mealTemplates
        )

        do {
            let data = try BackupManager.encode(payload)

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let filename = "WheytWatcher-backup-\(formatter.string(from: Date())).json"

            let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            try data.write(to: url, options: .atomic)

            exportURL = url
        } catch {
            exportErrorMessage = "Kon geen back-up maken. Probeer het opnieuw."
        }
    }

    private func handleImportSelection(_ result: Result<URL, Error>) {
        importErrorMessage = nil

        switch result {
        case .success(let url):
            let didStartAccessing = url.startAccessingSecurityScopedResource()
            defer {
                if didStartAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            do {
                let data = try Data(contentsOf: url)
                let payload = try BackupManager.decode(data)
                pendingImportPayload = payload
                showingRestoreConfirmation = true
            } catch {
                importErrorMessage = "Dit bestand kon niet gelezen worden. Is het een geldig Wheyt Watcher-back-up-bestand?"
            }

        case .failure:
            importErrorMessage = "Er ging iets mis bij het openen van het bestand."
        }
    }

    private func performRestore() {
        guard let payload = pendingImportPayload else { return }

        do {
            try BackupManager.restore(payload, into: modelContext)
            pendingImportPayload = nil
            showingRestoreSuccess = true
        } catch {
            importErrorMessage = "Terugzetten is niet gelukt. Probeer het opnieuw."
        }
    }

}
