import SwiftUI

enum MainTab: Hashable {
    case today, meals, favorites, logbook, progress
}

struct MainTabView: View {
    let profile: UserProfile

    @State private var selectedTab: MainTab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(profile: profile)
                .tabItem {
                    Label("Vandaag", systemImage: "house.fill")
                }
                .tag(MainTab.today)

            MealsView()
                .tabItem {
                    Label("Maaltijden", systemImage: "fork.knife")
                }
                .tag(MainTab.meals)

            FavoritesView(onAdded: { selectedTab = .today })
                .tabItem {
                    Label("Favorieten", systemImage: "heart.fill")
                }
                .tag(MainTab.favorites)

            LogbookView()
                .tabItem {
                    Label("Logboek", systemImage: "list.bullet.clipboard")
                }
                .tag(MainTab.logbook)

            ProgressViewScreen(profile: profile)
                .tabItem {
                    Label("Progressie", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(MainTab.progress)
        }
    }
}
//
//  MainTabView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//
