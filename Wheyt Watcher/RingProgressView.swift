import SwiftUI

struct RingProgressView: View {
    let title: String
    let current: Double
    let target: Double
    let unit: String
    let gradient: LinearGradient
    var lineWidth: CGFloat = 14
    var titleFont: Font = .caption
    var valueFont: Font = .title3.bold()
    var showLabels: Bool = true
    
    @State private var animatedProgress: Double = 0

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.wwDarkAccent.opacity(0.08),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    gradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            if showLabels {
                VStack(spacing: 2) {
                    if !title.isEmpty {
                        Text(title)
                            .font(titleFont)
                            .foregroundStyle(Color.wwDarkAccent.opacity(0.5))
                    }

                    Text("\(current.roundedInt)")
                        .font(valueFont)
                        .foregroundStyle(Color.wwDarkAccent)

                    Text("/ \(target.roundedInt) \(unit)")
                        .font(.caption2)
                        .foregroundStyle(Color.wwDarkAccent.opacity(0.5))
                }
                .minimumScaleFactor(0.6)
                .multilineTextAlignment(.center)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(current.roundedInt) van \(target.roundedInt) \(unit)")
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.1)) {
                animatedProgress = progress
            }
        }
        .onChange(of: current) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                animatedProgress = progress
            }
        }
    }
}

// Compacte ring voor macro's
struct CompactRingView: View {
    let title: String
    let current: Double
    let target: Double
    let unit: String
    let gradient: LinearGradient
    var lineWidth: CGFloat = 8
    
    @State private var animatedProgress: Double = 0

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                Circle()
                    .stroke(
                        Color.wwDarkAccent.opacity(0.08),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )

                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        gradient,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Text("\(current.roundedInt)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.wwDarkAccent)
            }
            .frame(width: 46, height: 46)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color.wwDarkAccent.opacity(0.6))
            
            Text("\(target.roundedInt)\(unit)")
                .font(.caption2)
                .foregroundStyle(Color.wwDarkAccent.opacity(0.4))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(current.roundedInt) van \(target.roundedInt) \(unit)")
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.15)) {
                animatedProgress = progress
            }
        }
        .onChange(of: current) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                animatedProgress = progress
            }
        }
    }
}
