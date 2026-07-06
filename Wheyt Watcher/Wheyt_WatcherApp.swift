import SwiftUI
import SwiftData

@main
struct WheytWatcherApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
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
            MealItem.self
        ])
    }
}
//
//  Wheyt_WatcherApp.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 03/07/2026.
//

