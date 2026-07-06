import SwiftUI
import SwiftData

struct MealsView: View {
    
    @Query(sort: \SavedMeal.createdAt, order: .reverse)
    private var savedMeals: [SavedMeal]
    @State private var showingSaveMeal = false
    
    
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

                                        VStack(alignment: .leading, spacing: 6) {

                                            Text(meal.name)
                                                .font(.headline)
                                                .foregroundStyle(Color.wwDarkAccent)

                                            Text("\(meal.items.count) ingrediënten")
                                                .font(.subheadline)
                                                .foregroundStyle(Color.wwSecondaryText)

                                            Text("\(Int(meal.items.reduce(0) { $0 + $1.calories })) kcal")
                                                .font(.caption)
                                                .foregroundStyle(Color.wwOrange)

                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(Color.wwSecondaryText)

                                    }
                                    .padding()
                                    .background(Color.wwCardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))

                                }
                                .buttonStyle(.plain)

                            }

                        }
                        .padding()

                    }
                        .navigationTitle("Maaltijden")
                    
                        .toolbar {
                            
                            ToolbarItem(placement: .topBarTrailing) {
                                
                                NavigationLinklabel: do {
                                    
                                    Image(systemName: "plus")
                                    
                                }
                                
                                
                            }
                            
                        }
                        .sheet(isPresented: $showingSaveMeal) {

                            SaveMealView(entries: [])

                        }
                    
                    
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
