import SwiftUI

struct MainTabView: View {
    let profile: UserProfile

    var body: some View {
        TabView {
            TodayView(profile: profile)
                .tabItem {
                    Label("Vandaag", systemImage: "house.fill")
                }
                .tint(Color.wwTeal)

            MealsView()
                .tabItem {
                    Label("Maaltijden", systemImage: "fork.knife")
                }
                .tint(Color.wwOrange)

            FavoritesView()
                .tabItem {
                    Label("Favorieten", systemImage: "heart.fill")
                }
                .tint(Color.wwCoral)

            LogbookView()
                .tabItem {
                    Label("Logboek", systemImage: "list.bullet.clipboard")
                }
                .tint(Color.wwAqua)

            ProgressViewScreen(profile: profile)
                .tabItem {
                    Label("Progressie", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tint(Color.wwBlue)
        }
    }
}
//
//  MainTabView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//
