import SwiftUI

struct AngleGaugeView: View {
    let angle: Double
    var target: Double = 120
    var tint: Color = .khBlue

    private var clampedProgress: Double {
        min(max(angle / target, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.12, to: 0.88)
                .stroke(Color.khSurfaceSecondary, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(90))

            Circle()
                .trim(from: 0.12, to: 0.12 + (0.76 * clampedProgress))
                .stroke(
                    LinearGradient(colors: [tint, .khMint], startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(90))

            VStack(spacing: 4) {
                Text("\(Int(angle.rounded()))")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)
                    .contentTransition(.numericText())

                Text("degrees")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextSecondary)
            }
        }
        .frame(width: 176, height: 176)
        .accessibilityLabel("Current knee angle \(Int(angle.rounded())) degrees")
    }
}

#Preview("Angle Gauge") {
    AngleGaugeView(angle: 82, target: 120)
        .padding()
        .background(Color.khBackground)
}
