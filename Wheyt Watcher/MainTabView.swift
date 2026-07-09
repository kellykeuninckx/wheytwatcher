import SwiftUI
import UIKit

struct MainTabView: View {
    let profile: UserProfile

    init(profile: UserProfile) {
        self.profile = profile

        // SwiftUI's .tint() gets overridden entirely once a custom UITabBarAppearance is set —
        // so both the active (selected) and inactive (normal) colors need to be configured here,
        // in one place, rather than mixing .tint() with a partially-configured appearance.
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        let activeColor = UIColor(Color.wwTeal)
        let inactiveColor = UIColor(Color.wwMint.opacity(0.45))

        for style in [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance] {
            style.selected.iconColor = activeColor
            style.selected.titleTextAttributes = [.foregroundColor: activeColor]
            style.normal.iconColor = inactiveColor
            style.normal.titleTextAttributes = [.foregroundColor: inactiveColor]
        }

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

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
