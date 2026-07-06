import SwiftUI
import SwiftData

struct MealsView: View {
    var body: some View {

        NavigationStack {

            WWScreen(accent: Color.wwOrange)  {

                WWPlaceholderCard(
                    icon: "fork.knife.circle.fill",
                    color: Color.wwOrange,
                    title: "Nog geen maaltijden",
                    message: "Sla straks een maaltijd op vanuit Vandaag om hem hier terug te vinden."
                )

            }
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

