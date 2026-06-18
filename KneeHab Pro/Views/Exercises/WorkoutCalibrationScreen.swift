import SwiftUI
import UIKit

struct WorkoutCalibrationScreen: View {
    @EnvironmentObject private var angleSource: AngleService
    @Environment(\.dismiss) private var dismiss

    let exercise: Exercise

    @State private var phase: Phase = .ready
    @State private var didStartCalibration = false
    @State private var errorMessage: String?

    private enum Phase {
        case ready
        case calibrating
        case complete
    }

    private var secondsRemaining: Int {
        max(0, Int(ceil(angleSource.calibrationRemainingSeconds)))
    }

    private var ringProgress: Double {
        switch phase {
        case .ready:
            0
        case .calibrating:
            min(max((3 - angleSource.calibrationRemainingSeconds) / 3, 0), 1)
        case .complete:
            1
        }
    }

    var body: some View {
        ZStack {
            CareBackground()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    topBar
                    heading
                    calibrationRing
                    positionPanel
                    if let errorMessage {
                        calibrationErrorPanel(errorMessage)
                    }
                    primaryControl
                }
                .frame(maxWidth: 440)
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 34)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if !angleSource.isStreaming {
                angleSource.start()
            }
        }
        .onChange(of: angleSource.isCalibrating) { wasCalibrating, isCalibrating in
            guard didStartCalibration,
                  angleSource.isConnected,
                  angleSource.calibrationError == nil,
                  wasCalibrating,
                  !isCalibrating else { return }
            playCompletionHaptic()
            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                phase = .complete
            }
        }
        .onChange(of: angleSource.isConnected) { _, isConnected in
            guard !isConnected else { return }
            didStartCalibration = false
            phase = .ready
        }
        .onChange(of: angleSource.calibrationError) { _, message in
            guard let message else { return }
            didStartCalibration = false
            phase = .ready
            errorMessage = message
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
        .onChange(of: secondsRemaining) { oldValue, newValue in
            guard phase == .calibrating,
                  newValue > 0,
                  newValue < 3,
                  newValue != oldValue else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
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
                Text("Workout Calibration")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.black)

                Text(exercise.name)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.48))
                    .lineLimit(1)
            }

            Spacer()

            StatusPill(
                text: statusLabel,
                icon: statusIcon,
                tint: statusTint
            )
        }
    }

    private var heading: some View {
        VStack(spacing: 7) {
            Text(headingTitle)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(Color.khTextPrimary)
                .multilineTextAlignment(.center)

            Text(headingSubtitle)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.khTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var calibrationRing: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.70))
                .frame(width: 248, height: 248)
                .shadow(color: .black.opacity(0.05), radius: 24, x: 0, y: 14)

            Circle()
                .stroke(Color.khSurfaceSecondary, lineWidth: 14)
                .frame(width: 210, height: 210)

            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(
                    LinearGradient(
                        colors: [Color.khCareGreen, Color.khMint, Color.khBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 210, height: 210)
                .animation(.linear(duration: 0.18), value: ringProgress)

            ringContent
        }
        .frame(height: 268)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityRingLabel)
    }

    @ViewBuilder
    private var ringContent: some View {
        switch phase {
        case .ready:
            VStack(spacing: 9) {
                Image(systemName: "scope")
                    .font(.system(size: 42, weight: .black))
                    .foregroundStyle(Color.khBlue)
                Text("Ready")
                    .font(.system(size: 25, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)
            }

        case .calibrating:
            VStack(spacing: 0) {
                Text("\(secondsRemaining)")
                    .font(.system(size: 78, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khCareGreen)
                    .contentTransition(.numericText())
                Text("seconds")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.khTextSecondary)
            }

        case .complete:
            VStack(spacing: 9) {
                Image(systemName: "checkmark")
                    .font(.system(size: 38, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 72, height: 72)
                    .background(Color.khCareGreen, in: Circle())
                Text("Calibrated")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)
            }
        }
    }

    private var positionPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 11) {
                Image(systemName: "figure.stand")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Color.khCareGreen)
                    .frame(width: 42, height: 42)
                    .background(Color.khCareGreen.opacity(0.13), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("Hold your starting pose")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(Color.khTextPrimary)

                    Text("Stay completely still until the countdown ends.")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.khTextSecondary)
                }
            }

            Divider()
                .overlay(Color.khBorder)

            HStack(spacing: 0) {
                readinessItem(
                    icon: angleSource.thighReceivingData ? "checkmark.circle.fill" : "xmark.circle.fill",
                    label: "Thigh",
                    value: sensorState(connected: angleSource.thighConnected, receiving: angleSource.thighReceivingData),
                    tint: sensorTint(connected: angleSource.thighConnected, receiving: angleSource.thighReceivingData)
                )
                readinessItem(
                    icon: angleSource.shinReceivingData ? "checkmark.circle.fill" : "xmark.circle.fill",
                    label: "Shin",
                    value: sensorState(connected: angleSource.shinConnected, receiving: angleSource.shinReceivingData),
                    tint: sensorTint(connected: angleSource.shinConnected, receiving: angleSource.shinReceivingData)
                )
                readinessItem(
                    icon: phase == .complete ? "lock.fill" : "figure.mind.and.body",
                    label: "Baseline",
                    value: phase == .complete ? "Locked" : "Hold still",
                    tint: phase == .complete ? .khBlue : .khOrange
                )
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.72), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 12)
    }

    @ViewBuilder
    private var primaryControl: some View {
        switch phase {
        case .ready:
            Button(action: startCalibration) {
                Label("Start Calibration", systemImage: "scope")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(Color.khCareLime, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.khCareGreen.opacity(0.22), radius: 16, x: 0, y: 10)
            }
            .buttonStyle(.plain)
            .disabled(!angleSource.isConnected)
            .opacity(angleSource.isConnected ? 1 : 0.48)

        case .calibrating:
            HStack(spacing: 9) {
                ProgressView()
                    .tint(.black)
                Text(angleSource.isConnected ? "Calibrating…" : "Waiting for sensors")
                    .font(.system(size: 16, weight: .black, design: .rounded))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

        case .complete:
            NavigationLink {
                ExerciseDetailScreen(exercise: exercise)
            } label: {
                HStack(spacing: 9) {
                    Text("Begin Workout")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(Color.black, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private func readinessItem(icon: String, label: String, value: String, tint: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(tint)
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color.khTextSecondary)
            Text(value)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
    }

    private func calibrationErrorPanel(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(Color.khRed)

            VStack(alignment: .leading, spacing: 4) {
                Text("Sensor data stopped")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)
                Text(message)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.khTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color.khRed.opacity(0.10), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.khRed.opacity(0.28), lineWidth: 1)
        }
    }

    private func sensorState(connected: Bool, receiving: Bool) -> String {
        if !connected { return "Offline" }
        return receiving ? "Data live" : "No data"
    }

    private func sensorTint(connected: Bool, receiving: Bool) -> Color {
        connected && receiving ? .khCareGreen : .khRed
    }

    private var headingTitle: String {
        switch phase {
        case .ready: "Set your starting pose"
        case .calibrating: "Hold still"
        case .complete: "Calibration complete"
        }
    }

    private var headingSubtitle: String {
        switch phase {
        case .ready: "Get into the position where this workout should begin."
        case .calibrating: "Your current sensor orientation is becoming zero."
        case .complete: "Your starting pose is now the zero reference."
        }
    }

    private var statusLabel: String {
        switch phase {
        case .ready: angleSource.isConnected ? "Ready" : "Sensors offline"
        case .calibrating: "Calibrating"
        case .complete: "Complete"
        }
    }

    private var statusIcon: String {
        switch phase {
        case .ready: angleSource.isConnected ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
        case .calibrating: "timer"
        case .complete: "checkmark.seal.fill"
        }
    }

    private var statusTint: Color {
        switch phase {
        case .ready: angleSource.isConnected ? .khBlue : .khOrange
        case .calibrating: .khCareGreen
        case .complete: .khCareGreen
        }
    }

    private var accessibilityRingLabel: String {
        switch phase {
        case .ready: "Calibration ready"
        case .calibrating: "Calibration, \(secondsRemaining) seconds remaining"
        case .complete: "Calibration complete"
        }
    }

    private func startCalibration() {
        guard angleSource.isConnected else { return }
        errorMessage = nil
        didStartCalibration = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        if angleSource.beginCalibration() {
            phase = .calibrating
        } else {
            didStartCalibration = false
            phase = .ready
            errorMessage = angleSource.calibrationError
        }
    }

    private func playCompletionHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

#Preview("Workout Calibration") {
    NavigationStack {
        WorkoutCalibrationScreen(exercise: Exercise.placeholders[0])
    }
    .environmentObject(AngleService())
}
