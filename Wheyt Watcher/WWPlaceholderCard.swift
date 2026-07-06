import SwiftUI

struct WWPlaceholderCard: View {

    let icon: String
    let color: Color
    let title: String
    let message: String

    var body: some View {

        VStack(spacing: 24) {

            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(color)

            VStack(spacing: 8) {

                Text(title)
                    .font(.title2.bold())

                Text(message)
                    .font(.body)
                    .foregroundStyle(Color.wwSecondaryText)
                    .multilineTextAlignment(.center)

            }

        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .wwCard()

    }

}//
//  WWPlaceholderCard.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 06/07/2026.
//

