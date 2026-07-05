import SwiftUI

struct QuickAddView: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var showingAddFood: Bool

    var body: some View {

        NavigationStack {

            List {

                Section {

                    Menu {

                        Button {

                            // TODO: Kopieer gisteren

                        } label: {

                            Label(
                                "Gisteren",
                                systemImage: "clock.arrow.circlepath"
                            )

                        }

                        Button {

                            // TODO: Kopieer vorige week

                        } label: {

                            Label(
                                "Vorige week",
                                systemImage: "calendar"
                            )

                        }

                        Button {

                            // TODO: Kies een datum

                        } label: {

                            Label(
                                "Andere dag...",
                                systemImage: "calendar.badge.plus"
                            )

                        }

                    } label: {

                        Label(
                            "📅 Kopieer",
                            systemImage: "arrow.triangle.branch"
                        )

                    }

                    Button {

                        // TODO: Barcode scanner

                    } label: {

                        Label(
                            "📷 Scan barcode",
                            systemImage: "barcode.viewfinder"
                        )

                    }

                    Button {

                        // TODO: Favorieten

                    } label: {

                        Label(
                            "⭐ Favorieten",
                            systemImage: "star.fill"
                        )

                    }

                    Button {

                        // TODO: Maaltijden

                    } label: {

                        Label(
                            "🍽️ Maaltijden",
                            systemImage: "fork.knife.circle"
                        )

                    }

                    Button {

                        dismiss()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {

                            showingAddFood = true

                        }

                    } label: {

                        Label(
                            "🔍 Zoek product",
                            systemImage: "magnifyingglass"
                        )

                    }

                }

            }
            .navigationTitle("Voeg voeding toe")
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

    QuickAddView(showingAddFood: .constant(false))

}
//
//  QuickAddView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 04/07/2026.
//

