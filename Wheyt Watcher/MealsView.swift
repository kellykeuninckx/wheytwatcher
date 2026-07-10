import SwiftUI
import SwiftData

struct MealsView: View {
    
    @Query(sort: \SavedMeal.createdAt, order: .reverse)
    private var savedMeals: [SavedMeal]

    @Environment(\.modelContext) private var modelContext
    @State private var mealPendingDeletion: SavedMeal?

    var body: some View {
        
        NavigationStack {
            
            WWScreen(accent: Color.wwOrange)  {
                
                if savedMeals.isEmpty {
                    
                    WWPlaceholderCard(
                        icon: "fork.knife.circle.fill",
                        color: Color.wwOrange,
                        title: "Nog geen maaltijden",
                        message: "Sla een maaltijd op vanuit je logboek."
                    )
                    
                } else {
                    ScrollView {

                        LazyVStack(spacing: 16) {

                            ForEach(savedMeals) { meal in

                                NavigationLink {

                                    MealDetailView(meal: meal)

                                } label: {

                                    HStack {
                                        
                                        Image(systemName: "fork.knife.circle.fill")
                                                .foregroundStyle(Color.wwOrange)

                                        VStack(alignment: .leading, spacing: 2) {

                                            Text(meal.name)
                                                .font(.headline)
                                                .foregroundStyle(Color.wwDarkAccent)

                                            Text("\(meal.items.count) ingrediënten • \(Int(meal.items.reduce(0) { $0 + $1.calories })) kcal")
                                                .font(.caption)
                                                .foregroundStyle(Color.wwSecondaryText)

                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(Color.wwSecondaryText)

                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .wwCard()

                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        mealPendingDeletion = meal
                                    } label: {
                                        Label("Verwijder", systemImage: "trash")
                                    }
                                }

                            }

                        }

                    }
                        .navigationTitle("Maaltijden")
                    
                }
                
            }
            .alert(
                "Maaltijd verwijderen?",
                isPresented: Binding(
                    get: { mealPendingDeletion != nil },
                    set: { if !$0 { mealPendingDeletion = nil } }
                )
            ) {
                Button("Annuleer", role: .cancel) {
                    mealPendingDeletion = nil
                }
                Button("Verwijder", role: .destructive) {
                    if let meal = mealPendingDeletion {
                        modelContext.delete(meal)
                        try? modelContext.save()
                    }
                    mealPendingDeletion = nil
                }
            } message: {
                Text("Dit verwijdert alleen de opgeslagen maaltijd zelf — je logboek blijft ongewijzigd.")
            }
        }
    }
}
//
//  MealsView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 06/07/2026.
//
