import SwiftUI
import UIKit

struct SeatedKneeExtensionScreen: View {
    @EnvironmentObject private var angleSource: AngleService
    @Environment(\.dismiss) private var dismiss

    let exercise: Exercise

    @State private var phase: SessionPhase = .ready
    @State private var completedReps = 0
    @State private var countdown = 3
    @State private var wasAtStart = true
    @State private var countdownTask: Task<Void, Never>?
    @State private var showTargetAlert = false
    @State private var hasWarnedThisRep = false

    private enum SessionPhase {
        case ready
        case countdown
        case workout
        case paused
        case complete
    }

    private let targetAngle = 70.0
    private let resetAngle = 15.0

    private var displayAngle: Double {
        switch phase {
        case .ready, .countdown:
            0
        case .workout, .paused:
            min(max(angleSource.angle, 0), 90)
        case .complete:
            targetAngle
        }
    }

    private var targetProgress: Double {
        min(displayAngle / targetAngle, 1)
    }

    var body: some View {
        ZStack {
            CareBackground()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    topBar
                    workoutSurface
                    controls
                    safetyGuidelines
                }
                .frame(maxWidth: 440)
                .padding(.horizontal, 18)
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
        .onChange(of: angleSource.angle) { _, newAngle in
            handleAngleChange(newAngle)
        }
        .onDisappear {
            countdownTask?.cancel()
        }
        .alert("Target exceeded", isPresented: $showTargetAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The set has been paused. Return slowly toward the calibrated starting position before resuming.")
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
                Text("Seated Knee Extension")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)

                Text("Set 1 of \(exercise.sets)  ·  \(exercise.reps) reps")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.48))
            }

            Spacer(minLength: 4)

            StatusPill(text: statusText, icon: statusIcon, tint: statusTint)
        }
    }

    private var workoutSurface: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(feedbackTitle)
                        .font(.system(size: 27, weight: .black, design: .rounded))
                        .foregroundStyle(Color.khTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)

                    Text(feedbackSubtitle)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.khTextSecondary)
                }

                Spacer()

                repCounter
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 8)

            ZStack(alignment: .topTrailing) {
                LegVisualizer(angle: displayAngle)
                    .frame(height: 278)
                    .padding(.horizontal, 8)

                angleBadge
                    .padding(.trailing, 16)
                    .padding(.top, 10)

                if phase == .countdown {
                    countdownOverlay
                } else if phase == .complete {
                    completionOverlay
                }
            }

            progressSection
                .padding(.horizontal, 20)
                .padding(.top, 2)
                .padding(.bottom, 20)
        }
        .background(Color.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.74), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.07), radius: 24, x: 0, y: 16)
    }

    private var repCounter: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text("\(completedReps)")
                .font(.system(size: 31, weight: .black, design: .rounded))
            Text("/\(exercise.reps)")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(.black.opacity(0.46))
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.khCareLime.opacity(0.70), in: Capsule())
    }

    private var angleBadge: some View {
        VStack(spacing: 0) {
            Text("\(Int(displayAngle.rounded()))°")
                .font(.system(size: 24, weight: .black, design: .rounded))
            Text("EXTENSION")
                .font(.system(size: 8, weight: .black, design: .rounded))
        }
        .foregroundStyle(.white)
        .frame(width: 76, height: 60)
        .background(Color.khBlue, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.khBlue.opacity(0.22), radius: 12, x: 0, y: 7)
    }

    private var progressSection: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Extension range")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextSecondary)

                Spacer()

                Text("Target \(Int(targetAngle))°")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.khSurfaceSecondary)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.khBlue, Color.khMint, Color.khCareGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * targetProgress)
                        .animation(.easeOut(duration: 0.18), value: targetProgress)
                }
            }
            .frame(height: 12)
        }
    }

    private var controls: some View {
        HStack(spacing: 10) {
            Button(action: primaryAction) {
                HStack(spacing: 9) {
                    Image(systemName: primaryIcon)
                    Text(primaryTitle)
                }
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(primaryForeground)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(primaryBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: primaryShadow, radius: 16, x: 0, y: 10)
            }
            .buttonStyle(.plain)
            .disabled(phase == .countdown)

            Button(action: resetSession) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Color.khTextPrimary)
                    .frame(width: 58, height: 58)
                    .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 8)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Reset set")
        }
    }

    private var safetyGuidelines: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(Color.khOrange)

                Text("Safety Guidelines")
                    .font(.system(size: 19, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)
            }

            safetyRow(icon: "exclamationmark.triangle.fill", text: "Stop immediately if you feel sharp pain.", tint: .khRed)
            safetyRow(icon: "clock.arrow.circlepath", text: "Move slowly and with control.", tint: .khOrange)
            safetyRow(icon: "lungs.fill", text: "Breathe normally throughout the set.", tint: .khCareGreen)
            safetyRow(icon: "figure.seated.side", text: "Maintain a stable seated posture.", tint: .khBlue)
        }
        .padding(18)
        .background(Color.khCareCream.opacity(0.90), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.khOrange.opacity(0.30), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 7)
    }

    private func safetyRow(icon: String, text: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(tint)
                .frame(width: 20)

            Text(text)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.khTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
    }

    private var countdownOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.92))

            VStack(spacing: 2) {
                Text("\(countdown)")
                    .font(.system(size: 104, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khBlue)
                    .contentTransition(.numericText())
                Text("GET READY")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextSecondary)
            }
        }
        .padding(.horizontal, 8)
    }

    private var completionOverlay: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 30, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(Color.khCareGreen, in: Circle())

            Text("Set complete")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(Color.khTextPrimary)

            Text("\(exercise.reps) controlled repetitions")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.khTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.93), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 8)
    }

    private var feedbackTitle: String {
        switch phase {
        case .ready: return "Ready for set one"
        case .countdown: return "Starting soon"
        case .paused: return "Set paused"
        case .complete: return "Set complete"
        case .workout:
            if displayAngle >= targetAngle { return "Target reached" }
            if displayAngle >= 50 { return "Keep lifting" }
            if displayAngle >= 20 { return "Smooth and steady" }
            return "Begin the extension"
        }
    }

    private var feedbackSubtitle: String {
        switch phase {
        case .ready: "Start when you are settled in the calibrated pose."
        case .countdown: "Hold the starting pose until the live set begins."
        case .workout: "Lift to the target, then return to the start."
        case .paused: "Your repetition count is saved."
        case .complete: "All repetitions are recorded."
        }
    }

    private var statusText: String {
        switch phase {
        case .ready: "Ready"
        case .countdown: "Starting"
        case .workout: "Live"
        case .paused: "Paused"
        case .complete: "Complete"
        }
    }

    private var statusIcon: String {
        switch phase {
        case .ready: "checkmark.circle.fill"
        case .countdown: "timer"
        case .workout: "waveform.path.ecg"
        case .paused: "pause.fill"
        case .complete: "checkmark.seal.fill"
        }
    }

    private var statusTint: Color {
        switch phase {
        case .ready, .workout: .khBlue
        case .countdown, .complete: .khCareGreen
        case .paused: .khOrange
        }
    }

    private var primaryTitle: String {
        switch phase {
        case .ready: "Start Set"
        case .countdown: "Starting"
        case .workout: "Pause"
        case .paused: "Resume"
        case .complete: "Repeat Set"
        }
    }

    private var primaryIcon: String {
        switch phase {
        case .ready: "play.fill"
        case .countdown: "timer"
        case .workout: "pause.fill"
        case .paused: "play.fill"
        case .complete: "arrow.clockwise"
        }
    }

    private var primaryForeground: Color {
        phase == .workout ? .white : .black
    }

    private var primaryBackground: Color {
        phase == .workout ? .black : .khCareLime
    }

    private var primaryShadow: Color {
        phase == .workout ? .black.opacity(0.16) : Color.khCareGreen.opacity(0.20)
    }

    private func primaryAction() {
        switch phase {
        case .ready:
            startCountdown()
        case .countdown:
            break
        case .workout:
            phase = .paused
        case .paused:
            phase = .workout
        case .complete:
            resetSession()
            startCountdown()
        }
    }

    private func startCountdown() {
        countdownTask?.cancel()
        phase = .countdown
        countdown = 3
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        countdownTask = Task { @MainActor in
            for nextValue in [2, 1, 0] {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                countdown = nextValue

                if nextValue > 0 {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    phase = .workout
                    wasAtStart = true
                    countdownTask = nil
                }
            }
        }
    }

    private func updateRepCount(with angle: Double) {
        guard phase == .workout, completedReps < exercise.reps else { return }

        if angle <= resetAngle {
            wasAtStart = true
            hasWarnedThisRep = false
        } else if angle >= targetAngle, wasAtStart {
            completedReps += 1
            wasAtStart = false
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

            if completedReps >= exercise.reps {
                phase = .complete
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }

    private func handleAngleChange(_ angle: Double) {
        guard phase == .workout else { return }

        if angle > targetAngle + 5, !hasWarnedThisRep {
            hasWarnedThisRep = true
            phase = .paused
            showTargetAlert = true
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }

        updateRepCount(with: angle)
    }

    private func resetSession() {
        countdownTask?.cancel()
        countdownTask = nil
        completedReps = 0
        countdown = 3
        wasAtStart = true
        hasWarnedThisRep = false
        showTargetAlert = false
        phase = .ready
    }
}

#Preview("Seated Knee Extension") {
    NavigationStack {
        SeatedKneeExtensionScreen(exercise: Exercise.placeholders[0])
    }
    .environmentObject(AngleService())
}
