import SwiftUI
import SwiftData

@main
struct WheytWatcherApp: App {

    @StateObject private var purchaseManager = PurchaseManager()

    init() {
        configureTabBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(purchaseManager)
        }
        .modelContainer(for: [
            UserProfile.self,
            FoodProduct.self,
            FoodLogEntry.self,
            MealTemplate.self,
            TrainingSession.self,
            WeightLog.self,
            DailyTargetSnapshot.self,
            FavoriteFood.self,
            SavedMeal.self,
            MealItem.self,
            GoalPeriod.self,
            DayStatus.self,
            BodyMeasurementLog.self
        ])
    }

    /// Moet zo vroeg mogelijk gebeuren — UIAppearance-proxy-instellingen worden alleen
    /// toegepast op tabbalken die ná dit moment worden aangemaakt.
    private func configureTabBarAppearance() {
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
}
//
//  Wheyt_WatcherApp.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 03/07/2026.
//
