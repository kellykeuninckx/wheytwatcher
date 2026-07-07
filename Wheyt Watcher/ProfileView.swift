import SwiftUI

struct ProfileView: View {

    let profile: UserProfile

    var body: some View {

        NavigationStack {

            WWScreen(accent: .wwPurple) {

                VStack(spacing: 20) {

                    Text(profile.name)
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.wwDarkAccent)

                    Text("Profiel wordt binnenkort uitgebreid.")
                        .foregroundStyle(Color.wwSecondaryText)

                }
                .padding()

            }
            .navigationTitle("Profiel")

        }

    }

}//
//  ProfileView.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 07/07/2026.
//

