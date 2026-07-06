import SwiftUI

struct WWScreen<Content: View>: View {

    let accent: Color

    @ViewBuilder let content: Content

    init(
        accent: Color = Color.wwTeal,
        @ViewBuilder content: () -> Content
    ) {
        self.accent = accent
        self.content = content()
    }

    var body: some View {

        ZStack {

            DumbbellPatternBackground()

            content
                .padding(.horizontal)

        }
        .tint(accent)

    }

}//
//  wwScreen.swift
//  Wheyt Watcher
//
//  Created by Kelly Keuninckx on 06/07/2026.
//

