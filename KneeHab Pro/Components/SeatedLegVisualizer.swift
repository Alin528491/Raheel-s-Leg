import SwiftUI

struct SeatedLegVisualizer: View {
    let angle: Double
    var showTrace = true

    private var kneeBend: Double {
        min(max(angle, 0), 130)
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let scale = min(size.width / 330, size.height / 250)
            let hip = CGPoint(x: size.width * 0.31, y: size.height * 0.36)
            let thighLength = 88 * scale
            let shinLength = 102 * scale
            let knee = CGPoint(x: hip.x + thighLength, y: hip.y + 20 * scale)
            let shinDirection = CGFloat((18 + kneeBend * 0.78) * .pi / 180)
            let ankle = CGPoint(
                x: knee.x + cos(shinDirection) * shinLength,
                y: knee.y + sin(shinDirection) * shinLength
            )

            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.khSurfaceSecondary, .white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                chair(in: size, scale: scale)

                if showTrace {
                    traceArc(center: knee, radius: shinLength, scale: scale)
                }

                bodyShape(hip: hip, knee: knee, ankle: ankle, scale: scale)
            }
        }
        .frame(height: 252)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.khBorder, lineWidth: 1)
        )
        .accessibilityLabel("Seated leg movement visual")
    }

    private func chair(in size: CGSize, scale: CGFloat) -> some View {
        Path { path in
            let seat = CGRect(x: size.width * 0.22, y: size.height * 0.43, width: 112 * scale, height: 14 * scale)
            path.addRoundedRect(in: seat, cornerSize: CGSize(width: 7 * scale, height: 7 * scale))
            path.move(to: CGPoint(x: seat.minX + 16 * scale, y: seat.maxY))
            path.addLine(to: CGPoint(x: seat.minX + 10 * scale, y: seat.maxY + 86 * scale))
            path.move(to: CGPoint(x: seat.maxX - 14 * scale, y: seat.maxY))
            path.addLine(to: CGPoint(x: seat.maxX - 4 * scale, y: seat.maxY + 86 * scale))
            path.move(to: CGPoint(x: seat.minX + 3 * scale, y: seat.minY))
            path.addLine(to: CGPoint(x: seat.minX - 16 * scale, y: seat.minY - 96 * scale))
        }
        .stroke(Color.khTextSecondary.opacity(0.36), style: StrokeStyle(lineWidth: 8 * scale, lineCap: .round, lineJoin: .round))
    }

    private func traceArc(center: CGPoint, radius: CGFloat, scale: CGFloat) -> some View {
        Path { path in
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(18),
                endAngle: .degrees(120),
                clockwise: false
            )
        }
        .stroke(Color.khBlue.opacity(0.16), style: StrokeStyle(lineWidth: 10 * scale, lineCap: .round, dash: [2 * scale, 15 * scale]))
    }

    private func bodyShape(hip: CGPoint, knee: CGPoint, ankle: CGPoint, scale: CGFloat) -> some View {
        ZStack {
            Capsule()
                .fill(Color.khTextPrimary)
                .frame(width: 52 * scale, height: 96 * scale)
                .rotationEffect(.degrees(-8))
                .position(x: hip.x - 38 * scale, y: hip.y - 45 * scale)

            Circle()
                .fill(Color.khTextPrimary)
                .frame(width: 42 * scale, height: 42 * scale)
                .position(x: hip.x - 54 * scale, y: hip.y - 112 * scale)

            limb(from: hip, to: knee, width: 25 * scale, color: .khBlueDark)
            limb(from: knee, to: ankle, width: 24 * scale, color: .khBlue)

            Circle()
                .fill(Color.khMint)
                .frame(width: 38 * scale, height: 38 * scale)
                .position(knee)

            Circle()
                .stroke(.white, lineWidth: 5 * scale)
                .frame(width: 25 * scale, height: 25 * scale)
                .position(knee)

            RoundedRectangle(cornerRadius: 8 * scale, style: .continuous)
                .fill(Color.khTextPrimary)
                .frame(width: 58 * scale, height: 18 * scale)
                .rotationEffect(.degrees(12 + kneeBend * 0.5))
                .position(x: ankle.x + 22 * scale, y: ankle.y + 6 * scale)
        }
    }

    private func limb(from start: CGPoint, to end: CGPoint, width: CGFloat, color: Color) -> some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
    }
}

#Preview("Seated Leg Visualizer") {
    VStack(spacing: 16) {
        SeatedLegVisualizer(angle: 18)
        SeatedLegVisualizer(angle: 86)
    }
    .padding()
    .background(Color.khBackground)
}
