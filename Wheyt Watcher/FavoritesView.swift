import SwiftUI
import SwiftData

struct FavoritesView: View {

    @Query private var favorites: [FavoriteFood]
    @Environment(\.modelContext) private var modelContext

    @State private var selectedFavorite: FavoriteFood?

    var body: some View {

        NavigationStack {

            ZStack {

                DumbbellPatternBackground()

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
                                                .foregroundStyle(.secondary)
                                            
                                        }
                                        .padding()

                                        .background(
                                            Color.wwCoral.opacity(0.08)
                                        )

                                        .clipShape(
                                            RoundedRectangle(
                                                cornerRadius: 20,
                                                style: .continuous
                                            )
                                        )

                                        .shadow(
                                            color: .black.opacity(0.05),
                                            radius: 8,
                                            y: 3
                                        )
                                        
                                        Spacer()
                                        
                                    }
                                    
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

#Preview {
    FavoritesView()
}
        //
        //  FavoritesView.swift
        //  Wheyt Watcher
        //
        //  Created by Kelly Keuninckx on 06/07/2026.
        //
    
