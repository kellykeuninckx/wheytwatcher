import SwiftUI
import SwiftData
import VisionKit

struct BarcodeScannerView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var products: [FoodProduct]

    @State private var scannedBarcode: String?
    @State private var isLookingUp = false
    @State private var lookupResult: FoodProduct?
    @State private var showingNotFoundAlert = false
    @State private var showingManualAdd = false

    private var scannerIsSupported: Bool {
        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }

    var body: some View {

        NavigationStack {

            ZStack {

                if scannerIsSupported {

                    BarcodeScannerRepresentable(onScan: handleScan)
                        .ignoresSafeArea()

                    if isLookingUp {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()

                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(.white)
                            Text("Product opzoeken…")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                        }
                        .padding(24)
                        .background(Color.wwCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }

                } else {

                    ZStack {
                        DumbbellPatternBackground()

                        WWPlaceholderCard(
                            icon: "barcode.viewfinder",
                            color: .wwOrange,
                            title: "Scanner niet beschikbaar",
                            message: "Barcode scannen vereist een echt toestel met camera — dit werkt niet in de simulator."
                        )
                        .padding()
                    }

                }

            }
            .navigationTitle("Scan barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $lookupResult) { product in
                FoodProductQuickAddView(product: product) {
                    dismiss()
                }
            }
            .alert("Niet gevonden", isPresented: $showingNotFoundAlert) {
                Button("Handmatig toevoegen") {
                    showingManualAdd = true
                }
                Button("Annuleer", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("We konden dit product niet vinden in onze database. Wil je het handmatig toevoegen?")
            }
            .sheet(isPresented: $showingManualAdd, onDismiss: { dismiss() }) {
                AddFoodView(prefilledBarcode: scannedBarcode)
            }

        }

    }

    private func handleScan(_ barcode: String) {
        guard scannedBarcode != barcode else { return }
        scannedBarcode = barcode

        if let existing = products.first(where: { $0.barcode == barcode }) {
            lookupResult = existing
            return
        }

        isLookingUp = true

        Task {
            do {
                if let remote = try await OpenFoodFactsService.lookup(barcode: barcode) {
                    let product = FoodProduct(
                        name: remote.name,
                        brand: remote.brand,
                        barcode: barcode,
                        caloriesPer100g: remote.caloriesPer100g,
                        proteinPer100g: remote.proteinPer100g,
                        carbsPer100g: remote.carbsPer100g,
                        fatPer100g: remote.fatPer100g,
                        fiberPer100g: remote.fiberPer100g
                    )

                    await MainActor.run {
                        modelContext.insert(product)
                        try? modelContext.save()
                        isLookingUp = false
                        lookupResult = product
                    }
                } else {
                    await MainActor.run {
                        isLookingUp = false
                        showingNotFoundAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLookingUp = false
                    showingNotFoundAlert = true
                }
            }
        }
    }

}

// MARK: - VisionKit-wrapper

struct BarcodeScannerRepresentable: UIViewControllerRepresentable {

    let onScan: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        if !uiViewController.isScanning {
            try? uiViewController.startScanning()
        }
    }

    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan)
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {

        let onScan: (String) -> Void

        init(onScan: @escaping (String) -> Void) {
            self.onScan = onScan
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didAdd addedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            for item in addedItems {
                if case .barcode(let barcode) = item, let payload = barcode.payloadStringValue {
                    onScan(payload)
                    return
                }
            }
        }

    }

}//
//  BarcodeScannerView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 08/07/2026.
//

