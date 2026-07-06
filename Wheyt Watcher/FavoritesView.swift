import SwiftUI
import SwiftData

struct FavoritesView: View {

    @Query private var favorites: [FavoriteFood]

    var body: some View {
        NavigationStack {

            Group {

                if favorites.isEmpty {

                    ContentUnavailableView(
                        "Nog geen favorieten",
                        systemImage: "star",
                        description: Text("Voeg producten toe aan je favorieten vanuit je logboek.")
                    )

                } else {

                    List(favorites) { favorite in

                        Text(favorite.name)

                    }

                }

            }
            .navigationTitle("Favorieten")
            .navigationBarTitleDisplayMode(.inline)

        }
    }
}

#Preview {
    FavoritesView()
}//
//  FavoritesView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 06/07/2026.
//

