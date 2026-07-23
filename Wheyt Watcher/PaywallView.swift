import SwiftUI
import StoreKit

struct PaywallView: View {

    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    @State private var isPurchasing = false
    @State private var isRestoring = false

    var body: some View {
        NavigationStack {
            ZStack {

                DumbbellPatternBackground()

                ScrollView {
                    VStack(spacing: 24) {

                        VStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.wwOrange)

                            Text("Whey, mate! Premium")
                                .font(.title2.bold())
                                .foregroundStyle(Color.wwDarkAccent)

                            Text("Eenmalige aankoop — geen abonnement, geen verborgen kosten.")
                                .font(.subheadline)
                                .foregroundStyle(Color.wwSecondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)

                        VStack(alignment: .leading, spacing: 14) {
                            featureRow(icon: "barcode.viewfinder", text: "Barcode scanner")
                            featureRow(icon: "chart.line.uptrend.xyaxis", text: "Uitvergrote grafieken & langere geschiedenis")
                            featureRow(icon: "chart.pie.fill", text: "Gedetailleerd macro-overzicht per dag")
                            featureRow(icon: "sparkles", text: "De slimme 2-wekelijkse check-in")
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .wwCard()

                        if purchaseManager.isLoadingProduct {

                            ProgressView("Productinformatie laden...")
                                .foregroundStyle(Color.wwSecondaryText)

                        } else if let product = purchaseManager.premiumProduct {

                            Button {
                                Task {
                                    isPurchasing = true
                                    await purchaseManager.purchasePremium()
                                    isPurchasing = false
                                    if purchaseManager.isPremiumUnlocked {
                                        dismiss()
                                    }
                                }
                            } label: {
                                Group {
                                    if isPurchasing {
                                        ProgressView()
                                    } else {
                                        Text("Ontgrendel voor \(product.displayPrice)")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.wwTeal)
                            .disabled(isPurchasing || isRestoring)

                        } else {

                            Text("Productinformatie kon niet geladen worden.")
                                .font(.footnote)
                                .foregroundStyle(Color.wwSecondaryText)

                        }

                        Button {
                            Task {
                                isRestoring = true
                                await purchaseManager.restorePurchases()
                                isRestoring = false
                                if purchaseManager.isPremiumUnlocked {
                                    dismiss()
                                }
                            }
                        } label: {
                            if isRestoring {
                                ProgressView()
                            } else {
                                Text("Terugzetten aankopen")
                            }
                        }
                        .font(.footnote)
                        .foregroundStyle(Color.wwSecondaryText)
                        .disabled(isPurchasing || isRestoring)

                        if let error = purchaseManager.purchaseErrorMessage {
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }

                    }
                    .padding()
                }

            }
            .tint(Color.wwTeal)
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.wwTeal)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.wwDarkAccent)

            Spacer()
        }
    }

}//
//  PaywallView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 14/07/2026.
//

