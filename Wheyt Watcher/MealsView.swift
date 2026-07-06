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
                    
                    Text("Aantal maaltijden: \(savedMeals.count)")
                    
                        .navigationTitle("Maaltijden")
                    
                        .toolbar {
                            
                            ToolbarItem(placement: .topBarTrailing) {
                                
                                Button {
                                    
                                    showingSaveMeal = true
                                    
                                } label: {
                                    
                                    Image(systemName: "plus")
                                    
                                }
                                
                                
                            }
                            
                        }
                        .sheet(isPresented: $showingSaveMeal) {
                            
                            SaveMealView()
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
