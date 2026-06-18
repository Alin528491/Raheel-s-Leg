import SwiftUI

struct SeatedKneeExtensionPreviewScreen: View {
    @Environment(\.dismiss) private var dismiss

    let exercise: Exercise

    var body: some View {
        ZStack {
            CareBackground()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    topBar
                    previewSurface
                    movementSteps
                    beginCalibrationButton
                }
                .frame(maxWidth: 440)
                .padding(.horizontal, 18)
                .padding(.top, 4)
                .padding(.bottom, 34)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.84), in: Circle())
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text("Seated Knee Extension")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)

                Text("Movement preview")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.48))
            }

            Spacer()

            StatusPill(text: "Preview", icon: "play.rectangle.fill", tint: .khBlue)
        }
    }

    private var previewSurface: some View {
        VStack(spacing: 8) {
            VStack(spacing: 4) {
                Text("Watch one repetition")
                    .font(.system(size: 27, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)

                Text("The animation repeats automatically.")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.khTextSecondary)
            }
            .padding(.top, 20)

            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                let angle = previewAngle(at: context.date)

                ZStack(alignment: .topTrailing) {
                    LegVisualizer(angle: angle)
                        .frame(height: 286)
                        .padding(.horizontal, 8)

                    Text("\(Int(angle.rounded()))°")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 70, height: 48)
                        .background(Color.khBlue, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.top, 12)
                        .padding(.trailing, 16)
                }
            }

            HStack(spacing: 8) {
                previewTag(icon: "chair.fill", text: "Thigh supported")
                previewTag(icon: "arrow.up.right", text: "Controlled lift")
            }
            .padding(.bottom, 20)
        }
        .background(Color.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.72), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.07), radius: 24, x: 0, y: 16)
    }

    private var movementSteps: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Movement")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(Color.khTextPrimary)

            step(number: 1, text: "Sit with the thigh supported and parallel to the chair seat.")
            step(number: 2, text: "Extend the knee smoothly toward the target.")
            step(number: 3, text: "Return to the calibrated starting pose to complete the rep.")
        }
        .padding(18)
        .background(Color.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 18, x: 0, y: 10)
    }

    private var beginCalibrationButton: some View {
        NavigationLink {
            WorkoutCalibrationScreen(exercise: exercise)
        } label: {
            HStack(spacing: 9) {
                Text("Continue to Calibration")
                Image(systemName: "arrow.right")
            }
            .font(.system(size: 17, weight: .black, design: .rounded))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(Color.khCareLime, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.khCareGreen.opacity(0.22), radius: 16, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }

    private func step(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(.black)
                .frame(width: 30, height: 30)
                .background(Color.khCareLime, in: Circle())

            Text(text)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.khTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
    }

    private func previewTag(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .black))
            Text(text)
                .font(.system(size: 11, weight: .black, design: .rounded))
        }
        .foregroundStyle(Color.khTextPrimary)
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(Color.khSurfaceSecondary, in: Capsule())
    }

    private func previewAngle(at date: Date) -> Double {
        let cycle = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 5)

        if cycle < 0.7 { return 0 }
        if cycle < 2.2 {
            return easedProgress((cycle - 0.7) / 1.5) * 70
        }
        if cycle < 2.9 { return 70 }
        if cycle < 4.4 {
            return (1 - easedProgress((cycle - 2.9) / 1.5)) * 70
        }
        return 0
    }

    private func easedProgress(_ value: Double) -> Double {
        0.5 - cos(value * .pi) / 2
    }
}

#Preview("Seated Extension Preview") {
    NavigationStack {
        SeatedKneeExtensionPreviewScreen(exercise: Exercise.placeholders[0])
    }
    .environmentObject(AngleService())
}
