import SwiftUI
import SwiftData

struct MealsView: View {
    
    @Query(sort: \SavedMeal.createdAt, order: .reverse)
    private var savedMeals: [SavedMeal]
    
    
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

                            }

                        }
                    

                    }
                        .navigationTitle("Maaltijden")
                    
                            
                    
                    
                }
                
                //
                //  MealsView.swift
                //  Wheyt Watcher
                //
                //  Created by Kelly Keuninckx on 06/07/2026.
                //
                
            }
        }
    }
}
