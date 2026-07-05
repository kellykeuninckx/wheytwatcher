import SwiftUI
import SwiftData

struct RootView: View {
    @Query private var profiles: [UserProfile]

    var body: some View {
        if let profile = profiles.first {
            MainTabView(profile: profile)
        } else {
            OnboardingView()
        }
    }
}
//
//  RootView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 05/07/2026.
//

