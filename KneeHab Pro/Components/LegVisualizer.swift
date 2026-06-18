import SwiftUI

struct LegVisualizer: View {
    let angle: Double
    var showTrace = true

    private var extensionAngle: Double {
        min(max(angle, 0), 90)
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let unit = min(size.width / 400, size.height / 340)

            // Ratios ported from preview.qml: hip(255,288), knee(369,288).
            let hip = CGPoint(x: size.width * 0.32, y: size.height * 0.49)
            let knee = CGPoint(x: hip.x + 102 * unit, y: hip.y)
            let shinLength = 96 * unit
            let shinDegrees = CGFloat(max(6, 88 - extensionAngle * 0.91))
            let shinRadians = shinDegrees * .pi / 180
            let ankle = CGPoint(
                x: knee.x + cos(shinRadians) * shinLength,
                y: knee.y + sin(shinRadians) * shinLength
            )

            ZStack {
                qmlChair(hip: hip, unit: unit)

                if showTrace {
                    motionRange(center: knee, radius: shinLength, unit: unit)
                }

                qmlHead(hip: hip, unit: unit)
                qmlTorso(hip: hip, unit: unit)
                outlinedLimb(
                    from: hip,
                    to: knee,
                    width: 19 * unit,
                    outline: 3 * unit,
                    fill: Color.khBlueDark
                )
                naturalArm(hip: hip, unit: unit)
                outlinedLimb(
                    from: knee,
                    to: ankle,
                    width: 19 * unit,
                    outline: 3 * unit,
                    fill: Color.khBlue
                )
                qmlFoot(at: ankle, shinDegrees: shinDegrees, unit: unit)
            }
        }
        .accessibilityLabel("Seated knee extension movement")
        .accessibilityValue("\(Int(extensionAngle.rounded())) degrees")
    }

    private func qmlChair(hip: CGPoint, unit: CGFloat) -> some View {
        let origin = CGPoint(x: hip.x - 30 * unit, y: hip.y + 13 * unit)

        return Path { path in
            path.move(to: origin)
            path.addLine(to: CGPoint(x: origin.x + 124 * unit, y: origin.y))

            path.move(to: origin)
            path.addLine(to: CGPoint(x: origin.x, y: origin.y - 95 * unit))

            path.move(to: CGPoint(x: origin.x + 22 * unit, y: origin.y))
            path.addLine(to: CGPoint(x: origin.x + 22 * unit, y: origin.y + 85 * unit))

            path.move(to: CGPoint(x: origin.x + 104 * unit, y: origin.y))
            path.addLine(to: CGPoint(x: origin.x + 104 * unit, y: origin.y + 85 * unit))
        }
        .stroke(
            Color.khTextSecondary.opacity(0.30),
            style: StrokeStyle(lineWidth: 6 * unit, lineCap: .round, lineJoin: .round)
        )
    }

    private func qmlHead(hip: CGPoint, unit: CGFloat) -> some View {
        // QML head: 47 x 47, centered 3.5 left and 137.5 above the hip.
        Circle()
            .fill(Color(hex: "#FFD7B5"))
            .frame(width: 47 * unit, height: 47 * unit)
            .overlay {
                Circle()
                    .stroke(Color.khBlueDark, lineWidth: 3 * unit)
            }
            .position(x: hip.x - 3.5 * unit, y: hip.y - 137.5 * unit)
    }

    private func qmlTorso(hip: CGPoint, unit: CGFloat) -> some View {
        // QML torso: 37 x 104, radius 18, positioned 22 left and 115 above hip.
        RoundedRectangle(cornerRadius: 18 * unit, style: .continuous)
            .fill(Color.khMint)
            .frame(width: 37 * unit, height: 104 * unit)
            .overlay {
                RoundedRectangle(cornerRadius: 18 * unit, style: .continuous)
                    .stroke(Color.khBlueDark, lineWidth: 4 * unit)
            }
            .position(
                x: hip.x - 22 * unit + 18.5 * unit,
                y: hip.y - 115 * unit + 52 * unit
            )
    }

    private func naturalArm(hip: CGPoint, unit: CGFloat) -> some View {
        let shoulder = CGPoint(x: hip.x + 6 * unit, y: hip.y - 88 * unit)
        let elbow = CGPoint(x: hip.x + 18 * unit, y: hip.y - 44 * unit)
        let hand = CGPoint(x: hip.x + 39 * unit, y: hip.y - 8 * unit)

        let upperArm = Path { path in
            path.move(to: shoulder)
            path.addQuadCurve(
                to: elbow,
                control: CGPoint(x: hip.x + 13 * unit, y: hip.y - 67 * unit)
            )
        }

        let forearm = Path { path in
            path.move(to: elbow)
            path.addQuadCurve(
                to: hand,
                control: CGPoint(x: hip.x + 20 * unit, y: hip.y - 28 * unit)
            )
        }

        return ZStack {
            upperArm.stroke(
                Color.khBlueDark,
                style: StrokeStyle(lineWidth: 16 * unit, lineCap: .round)
            )
            upperArm.stroke(
                Color.khMint,
                style: StrokeStyle(lineWidth: 10 * unit, lineCap: .round)
            )

            forearm.stroke(
                Color.khBlueDark,
                style: StrokeStyle(lineWidth: 14 * unit, lineCap: .round)
            )
            forearm.stroke(
                Color(hex: "#FFD7B5"),
                style: StrokeStyle(lineWidth: 9 * unit, lineCap: .round)
            )

            Capsule()
                .fill(Color(hex: "#FFD7B5"))
                .frame(width: 18 * unit, height: 10 * unit)
                .overlay {
                    Capsule()
                        .stroke(Color.khBlueDark, lineWidth: 2 * unit)
                }
                .rotationEffect(.degrees(8))
                .position(hand)
        }
    }

    private func motionRange(center: CGPoint, radius: CGFloat, unit: CGFloat) -> some View {
        ZStack {
            Path { path in
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(7),
                    endAngle: .degrees(88),
                    clockwise: false
                )
                path.closeSubpath()
            }
            .fill(Color.khCareLime.opacity(0.12))

            Path { path in
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(7),
                    endAngle: .degrees(24),
                    clockwise: false
                )
                path.closeSubpath()
            }
            .fill(Color.khCareGreen.opacity(0.22))

            Path { path in
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(7),
                    endAngle: .degrees(88),
                    clockwise: false
                )
            }
            .stroke(
                Color.khMint.opacity(0.70),
                style: StrokeStyle(lineWidth: 2.5 * unit, lineCap: .round, dash: [2 * unit, 6 * unit])
            )
        }
    }

    private func outlinedLimb(
        from start: CGPoint,
        to end: CGPoint,
        width: CGFloat,
        outline: CGFloat,
        fill: Color
    ) -> some View {
        ZStack {
            limb(from: start, to: end, width: width + outline * 2, color: .khBlueDark)
            limb(from: start, to: end, width: width, color: fill)
        }
    }

    private func qmlFoot(at ankle: CGPoint, shinDegrees: CGFloat, unit: CGFloat) -> some View {
        // QML foot: 60 x 25 centered on the shin endpoint.
        let footDegrees = shinDegrees - 90
        let footRadians = footDegrees * .pi / 180

        return RoundedRectangle(cornerRadius: 12 * unit, style: .continuous)
            .fill(Color.khTextPrimary)
            .frame(width: 60 * unit, height: 25 * unit)
            .overlay(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4 * unit, style: .continuous)
                    .fill(Color.khCareLime)
                    .frame(height: 8 * unit)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12 * unit, style: .continuous)
                    .stroke(Color.khBlueDark, lineWidth: 3 * unit)
            }
            .rotationEffect(.degrees(Double(footDegrees)))
            .position(
                x: ankle.x + cos(footRadians) * 20 * unit,
                y: ankle.y + sin(footRadians) * 20 * unit
            )
    }

    private func limb(from start: CGPoint, to end: CGPoint, width: CGFloat, color: Color) -> some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
    }
}

#Preview("Seated Extension Movement") {
    VStack(spacing: 18) {
        LegVisualizer(angle: 0)
            .frame(height: 250)
        LegVisualizer(angle: 70)
            .frame(height: 250)
    }
    .padding()
    .background(CareBackground())
}
