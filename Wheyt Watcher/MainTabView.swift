import SwiftUI

struct MainTabView: View {
    let profile: UserProfile

    var body: some View {
        TabView {
            TodayView(profile: profile)
                .tabItem {
                    Label("Vandaag", systemImage: "house.fill")
                }

            MealsView()
                .tabItem {
                    Label("Maaltijden", systemImage: "fork.knife")
                }
            FavoritesView()
                .tabItem {
                    Label("Favorieten", systemImage: "heart.fill")
                }

            LogbookView()
                .tabItem {
                    Label("Logboek", systemImage: "list.bullet.clipboard")
                }

            ProgressViewScreen(profile: profile)
                .tabItem {
                    Label("Progressie", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
    }
}
//
//  MainTabView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//
