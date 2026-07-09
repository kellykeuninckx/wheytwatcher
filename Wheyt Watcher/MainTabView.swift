import SwiftUI

struct MainTabView: View {
    let profile: UserProfile

    private enum Tab: Hashable {
        case today, meals, favorites, logbook, progress
    }

    @State private var selectedTab: Tab = .today

    private var currentTint: Color {
        switch selectedTab {
        case .today: return .wwTeal
        case .meals: return .wwOrange
        case .favorites: return .wwCoral
        case .logbook: return .wwAqua
        case .progress: return .wwBlue
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(profile: profile)
                .tabItem {
                    Label("Vandaag", systemImage: "house.fill")
                }
                .tag(Tab.today)

            MealsView()
                .tabItem {
                    Label("Maaltijden", systemImage: "fork.knife")
                }
                .tag(Tab.meals)

            FavoritesView()
                .tabItem {
                    Label("Favorieten", systemImage: "heart.fill")
                }
                .tag(Tab.favorites)

            LogbookView()
                .tabItem {
                    Label("Logboek", systemImage: "list.bullet.clipboard")
                }
                .tag(Tab.logbook)

            ProgressViewScreen(profile: profile)
                .tabItem {
                    Label("Progressie", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(Tab.progress)
        }
        .tint(currentTint)
    }
}
//
//  MainTabView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//
