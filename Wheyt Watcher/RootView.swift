import SwiftUI
import SwiftData

struct RootView: View {
    @Query private var profiles: [UserProfile]
    @AppStorage("wwIsDarkTheme") private var isDarkTheme: Bool = true

    var body: some View {
        Group {
            if let profile = profiles.first {
                MainTabView(profile: profile)
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(isDarkTheme ? .dark : .light)
        .environment(\.locale, Locale(identifier: "nl_NL"))
    }
}
//
//  RootView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//
