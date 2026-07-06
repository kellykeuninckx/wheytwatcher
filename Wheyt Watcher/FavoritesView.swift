import SwiftUI
import SwiftData

struct FavoritesView: View {
    
    @Query private var favorites: [FavoriteFood]
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedFavorite: FavoriteFood?
    
    var body: some View {
        
        NavigationStack {
            
            NavigationStack {
                
                WWScreen(accent: .wwCoral) {
                    
                    VStack {
                        
                        if favorites.isEmpty {
                            
                            ContentUnavailableView(
                                "Nog geen favorieten",
                                systemImage: "heart",
                                description: Text("Voeg producten toe aan je favorieten vanuit je logboek.")
                            )
                            
                        } else {
                            
                            ScrollView {
                                
                                LazyVStack(spacing: 16) {
                                    
                                    ForEach(favorites.sorted { $0.name < $1.name }) { favorite in
                                        
                                        Button {
                                            
                                            selectedFavorite = favorite
                                            
                                        } label: {
                                            
                                            HStack {
                                                
                                                Image(systemName: "heart.fill")
                                                    .foregroundStyle(Color.wwCoral)
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    
                                                    Text(favorite.name)
                                                        .font(.headline)
                                                        .foregroundStyle(Color.wwDarkAccent)
                                                    
                                                    Text("\(favorite.grams.roundedInt) g • \(favorite.calories.roundedInt) kcal")
                                                        .font(.caption)
                                                        .foregroundStyle(Color.wwSecondaryText)
                                                    
                                                }
                                                
                                                
                                                Spacer()
                                                
                                                Image(systemName: "chevron.right")
                                                    .font(.caption.weight(.semibold))
                                                    .foregroundStyle(Color.wwSecondaryText)
                                                
                                            }
                                            .padding()
                                            .wwCard()
                                            
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            
                        }
                        
                    }
                    .navigationTitle("Favorieten")
                    .navigationBarTitleDisplayMode(.large)
                    
                }
                .sheet(item: $selectedFavorite) { favorite in
                    
                    FavoriteQuickAddView(favorite: favorite)
                    
                }
                
            }
            
        }
        
    }
    
    
    //
    //  FavoritesView.swift
    //  Wheyt Watcher
    //
    //  Created by Kelly Keuninckx on 06/07/2026.
    //
    
}
