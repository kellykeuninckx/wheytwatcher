import SwiftUI
import UIKit

extension Color {

    // MARK: - Hoofdkleuren (gelijk in beide modi)

    static let wwBlue = Color(red: 0.10, green: 0.35, blue: 0.85)
    static let wwAqua = Color(red: 0.00, green: 0.75, blue: 0.80)
    static let wwTeal = Color(red: 0.00, green: 0.55, blue: 0.60)
    static let wwMint = Color(red: 0.35, green: 0.90, blue: 0.75)
    static let wwOrange = Color(red: 0.98, green: 0.63, blue: 0.28)
    static let wwCoral = Color(red: 0.96, green: 0.39, blue: 0.47)
    static let wwPurple = Color(red: 0.52, green: 0.42, blue: 0.93)

    // MARK: - Adaptieve kleuren (licht/donker) — volgen .preferredColorScheme

    // Hoofdkleur voor alle tekst
    static let wwDarkAccent = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white
            : UIColor(red: 0.08, green: 0.23, blue: 0.30, alpha: 1)
    })

    // Achtergrond (canvas)
    static let wwBackground = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.06, green: 0.13, blue: 0.17, alpha: 1)
            : UIColor(red: 0.88, green: 0.96, blue: 0.95, alpha: 1)
    })

    // Kaarten
    static let wwCardBackground = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.235, green: 0.40, blue: 0.431, alpha: 1)
            : UIColor.white
    })

    // Achtergrond van lege ringen
    static let wwRingBackground = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.14)
            : UIColor(red: 0.00, green: 0.55, blue: 0.60, alpha: 0.18)
    })

    // Secundaire tekst
    static let wwSecondaryText = Color.wwDarkAccent.opacity(0.60)

    // Tertiaire tekst
    static let wwTertiaryText = Color.wwDarkAccent.opacity(0.40)
}


extension LinearGradient {

    static let wwMain = LinearGradient(
        colors: [.wwBlue, .wwAqua],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let wwProtein = LinearGradient(
        colors: [.wwBlue, .wwAqua],
        startPoint: .top,
        endPoint: .bottom
    )

    static let wwCarbs = LinearGradient(
        colors: [.wwAqua, .wwTeal],
        startPoint: .top,
        endPoint: .bottom
    )

    static let wwFat = LinearGradient(
        colors: [.wwMint, .wwTeal],
        startPoint: .top,
        endPoint: .bottom
    )

    static let wwFiber = LinearGradient(
        colors: [.wwTeal, .wwMint],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Double {

    var roundedInt: Int {
        Int(self.rounded())
    }

}

// MARK: - Card Style

struct WWCardStyle: ViewModifier {

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(Color.wwCardBackground)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.06 : 0), lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.05),
                radius: 10,
                x: 0,
                y: 4
            )
    }

}

extension View {

    func wwCard() -> some View {
        modifier(WWCardStyle())
    }

}

// MARK: - Background

struct DumbbellPatternBackground: View {

    @Environment(\.colorScheme) private var colorScheme

    let iconCount = 35

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                Color.wwBackground
                    .ignoresSafeArea()

                ForEach(0..<iconCount, id: \.self) { index in

                    let position = randomPosition(
                        for: index,
                        in: geometry.size
                    )

                    let rotation = randomRotation(
                        for: index
                    )

                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            colorScheme == .dark
                                ? Color.white.opacity(0.04)
                                : Color.wwTeal.opacity(0.12)
                        )
                        .rotationEffect(.degrees(rotation))
                        .position(position)

                }

            }

        }

    }

    private func randomPosition(
        for index: Int,
        in size: CGSize
    ) -> CGPoint {

        let seed = index * 127

        let x = CGFloat(
            (seed * 31) % Int(max(size.width, 1))
        )

        let y = CGFloat(
            (seed * 47) % Int(max(size.height, 1))
        )

        return CGPoint(x: x, y: y)

    }

    private func randomRotation(
        for index: Int
    ) -> Double {

        let rotations: [Double] = [
            -25,
            -15,
            -5,
            5,
            15,
            25,
            35,
            -35,
            0,
            10,
            -10,
            20,
            -20
        ]

        return rotations[index % rotations.count]

    }

}

