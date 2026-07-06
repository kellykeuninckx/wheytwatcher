import SwiftUI
import SwiftData

struct MealsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Maaltijden",
                systemImage: "fork.knife",
                description: Text("Hier komen je herhaalmaaltijden. Dit bouwen we als volgende stap.")
            )
            .navigationTitle("Maaltijden")
        }
    }
}
//
//  MealsView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 06/07/2026.
//

