import SwiftUI
import UIKit

struct HeelSlideScreen: View {
    @EnvironmentObject private var angleSource: AngleService
    @Environment(\.dismiss) private var dismiss

    let exercise: Exercise

    @State private var phase: Phase = .ready
    @State private var completedReps = 0
    @State private var countdown = 3
    @State private var wasAtStart = true
    @State private var countdownTask: Task<Void, Never>?
    @State private var showTargetAlert = false
    @State private var hasWarnedThisRep = false

    private enum Phase {
        case ready
        case countdown
        case workout
        case paused
        case complete
    }

    private let targetAngle = 80.0
    private let resetAngle = 15.0

    private var displayAngle: Double {
        switch phase {
        case .ready, .countdown: 0
        case .workout, .paused: min(max(angleSource.angle, 0), 100)
        case .complete: targetAngle
        }
    }

    var body: some View {
        ZStack {
            CareBackground().ignoresSafeArea()

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
        .onChange(of: angleSource.angle) { _, angle in
            handleAngleChange(angle)
        }
        .onDisappear {
            countdownTask?.cancel()
        }
        .alert("Flexion target exceeded", isPresented: $showTargetAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The set has been paused. Slide the foot forward toward the calibrated start before resuming.")
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
                Text("Seated Knee Flexion")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

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
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(Color.khTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text(feedbackSubtitle)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.khTextSecondary)
                }

                Spacer()
                repCounter
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 6)

            ZStack(alignment: .topTrailing) {
                HeelSlideVisualizer(angle: displayAngle)
                    .frame(height: 286)
                    .padding(.horizontal, 8)

                angleBadge
                    .padding(.top, 10)
                    .padding(.trailing, 16)

                if phase == .countdown {
                    countdownOverlay
                } else if phase == .complete {
                    completionOverlay
                }
            }

            progressSection
                .padding(.horizontal, 20)
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
            Text("FLEXION")
                .font(.system(size: 8, weight: .black, design: .rounded))
        }
        .foregroundStyle(.white)
        .frame(width: 76, height: 60)
        .background(Color.khMint, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.khMint.opacity(0.24), radius: 12, x: 0, y: 7)
    }

    private var progressSection: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Knee flexion")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextSecondary)
                Spacer()
                Text("Target \(Int(targetAngle))°")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.khSurfaceSecondary)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [Color.khBlue, Color.khMint, Color.khCareGreen],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * min(displayAngle / targetAngle, 1))
                        .animation(.easeOut(duration: 0.18), value: displayAngle)
                }
            }
            .frame(height: 12)
        }
    }

    private var controls: some View {
        HStack(spacing: 10) {
            Button(action: primaryAction) {
                Label(primaryTitle, systemImage: primaryIcon)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(phase == .workout ? .white : .black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(
                        phase == .workout ? Color.black : Color.khCareLime,
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
            .disabled(phase == .countdown)

            Button(action: resetSession) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Color.khTextPrimary)
                    .frame(width: 58, height: 58)
                    .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Reset set")
        }
    }

    private var safetyGuidelines: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 9) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 19, weight: .black))
                    .foregroundStyle(Color.khOrange)
                Text("Safety Guidelines")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)
            }

            safetyRow("Stop if you feel sharp pain.", icon: "exclamationmark.triangle.fill", tint: .khRed)
            safetyRow("Keep the foot in contact with the floor.", icon: "shoeprints.fill", tint: .khBlue)
            safetyRow("Slide slowly without forcing the range.", icon: "arrow.left.and.right", tint: .khOrange)
        }
        .padding(18)
        .background(Color.khCareCream.opacity(0.90), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.khOrange.opacity(0.30), lineWidth: 1)
        }
    }

    private func safetyRow(_ text: String, icon: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(tint)
                .frame(width: 20)
            Text(text)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.khTextPrimary)
            Spacer(minLength: 0)
        }
    }

    private var countdownOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.93))
            VStack(spacing: 2) {
                Text("\(countdown)")
                    .font(.system(size: 104, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khMint)
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
        case .ready: return "Ready for heel slides"
        case .countdown: return "Starting soon"
        case .paused: return "Set paused"
        case .complete: return "Set complete"
        case .workout:
            if displayAngle >= targetAngle { return "Flexion target reached" }
            if displayAngle >= 55 { return "Slide a little farther" }
            if displayAngle >= 25 { return "Keep drawing the heel back" }
            return "Slide the heel back"
        }
    }

    private var feedbackSubtitle: String {
        switch phase {
        case .ready: "Start from the calibrated forward position."
        case .countdown: "Keep both feet still until tracking begins."
        case .workout: "Draw the working heel back, then slide forward."
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
        case .ready, .workout: .khMint
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

    private func primaryAction() {
        switch phase {
        case .ready: startCountdown()
        case .countdown: break
        case .workout: phase = .paused
        case .paused: phase = .workout
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
            for value in [2, 1, 0] {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                countdown = value
                if value > 0 {
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

    private func handleAngleChange(_ angle: Double) {
        guard phase == .workout else { return }

        if angle > targetAngle + 5, !hasWarnedThisRep {
            hasWarnedThisRep = true
            phase = .paused
            showTargetAlert = true
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }

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

struct HeelSlidePreviewScreen: View {
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise

    var body: some View {
        ZStack {
            CareBackground().ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    topBar
                    previewSurface
                    movementSteps
                    continueButton
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
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text("Seated Knee Flexion")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                Text("Movement preview")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.48))
            }
            Spacer()
            StatusPill(text: "Preview", icon: "play.rectangle.fill", tint: .khMint)
        }
    }

    private var previewSurface: some View {
        VStack(spacing: 7) {
            VStack(spacing: 4) {
                Text("Watch the heel slide")
                    .font(.system(size: 27, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)
                Text("The blue leg is the working leg.")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.khTextSecondary)
            }
            .padding(.top, 20)

            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                HeelSlideVisualizer(angle: previewAngle(at: context.date))
                    .frame(height: 292)
                    .padding(.horizontal, 8)
            }

            HStack(spacing: 8) {
                previewTag("Working leg", color: .khBlue)
                previewTag("Reference leg", color: .khTextSecondary.opacity(0.35))
            }
            .padding(.bottom, 20)
        }
        .background(Color.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 24, x: 0, y: 16)
    }

    private var movementSteps: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Movement")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(Color.khTextPrimary)
            step(1, "Begin with the working foot slightly forward.")
            step(2, "Slide the heel back while keeping the foot down.")
            step(3, "Slide forward to the calibrated start to complete the rep.")
        }
        .padding(18)
        .background(Color.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 18, x: 0, y: 10)
    }

    private var continueButton: some View {
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
        }
        .buttonStyle(.plain)
    }

    private func step(_ number: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .frame(width: 30, height: 30)
                .background(Color.khCareLime, in: Circle())
            Text(text)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.khTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    private func previewTag(_ text: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 9, height: 9)
            Text(text)
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(Color.khTextPrimary)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(Color.khSurfaceSecondary, in: Capsule())
    }

    private func previewAngle(at date: Date) -> Double {
        let cycle = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 5)
        if cycle < 0.7 { return 0 }
        if cycle < 2.2 { return eased((cycle - 0.7) / 1.5) * 80 }
        if cycle < 2.9 { return 80 }
        if cycle < 4.4 { return (1 - eased((cycle - 2.9) / 1.5)) * 80 }
        return 0
    }

    private func eased(_ value: Double) -> Double {
        0.5 - cos(value * .pi) / 2
    }
}

private struct HeelSlideVisualizer: View {
    let angle: Double

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let unit = min(size.width / 400, size.height / 340)
            let hip = CGPoint(x: size.width * 0.28, y: size.height * 0.44)
            let floorY = size.height * 0.84
            let heelY = floorY - 9 * unit
            let progress = CGFloat(min(max(angle, 0), 80) / 80)
            let forwardHeelX = size.width * 0.68
            let tuckedHeelX = size.width * 0.47
            let activeAnkle = CGPoint(
                x: forwardHeelX + (tuckedHeelX - forwardHeelX) * progress,
                y: heelY
            )
            let farHip = CGPoint(x: hip.x - 7 * unit, y: hip.y + 5 * unit)
            let farAnkle = CGPoint(x: size.width * 0.61, y: heelY + 3 * unit)
            let thighLength = 114 * unit
            let shinLength = 114 * unit
            let knee = kneePoint(hip: hip, ankle: activeAnkle, thigh: thighLength, shin: shinLength)
            let farKnee = kneePoint(hip: farHip, ankle: farAnkle, thigh: thighLength, shin: shinLength)

            ZStack {
                chair(hip: hip, unit: unit)
                floorLine(y: floorY, size: size, unit: unit)
                slideTrace(
                    from: CGPoint(x: tuckedHeelX, y: floorY + 13 * unit),
                    to: CGPoint(x: forwardHeelX + 34 * unit, y: floorY + 13 * unit),
                    unit: unit
                )

                outlinedLimb(from: farHip, to: farKnee, width: 17 * unit, outline: 3 * unit, fill: Color.khSurfaceSecondary)
                outlinedLimb(from: farKnee, to: farAnkle, width: 17 * unit, outline: 3 * unit, fill: Color.khTextSecondary.opacity(0.30))
                foot(at: farAnkle, unit: unit, fill: Color.khTextSecondary.opacity(0.34))

                head(hip: hip, unit: unit)
                torso(hip: hip, unit: unit)
                outlinedLimb(from: hip, to: knee, width: 19 * unit, outline: 3 * unit, fill: .khBlueDark)
                outlinedLimb(from: knee, to: activeAnkle, width: 19 * unit, outline: 3 * unit, fill: .khBlue)
                foot(at: activeAnkle, unit: unit, fill: .khTextPrimary)
                arm(hip: hip, unit: unit)
            }
        }
        .accessibilityLabel("Seated heel slide with working and reference legs")
        .accessibilityValue("\(Int(angle.rounded())) degrees flexion")
    }

    private func kneePoint(hip: CGPoint, ankle: CGPoint, thigh: CGFloat, shin: CGFloat) -> CGPoint {
        let dx = ankle.x - hip.x
        let dy = ankle.y - hip.y
        let rawDistance = sqrt(dx * dx + dy * dy)
        let distance = min(max(rawDistance, abs(thigh - shin) + 0.001), thigh + shin - 0.001)
        let along = (thigh * thigh - shin * shin + distance * distance) / (2 * distance)
        let height = sqrt(max(thigh * thigh - along * along, 0))
        let baseX = hip.x + along * dx / rawDistance
        let baseY = hip.y + along * dy / rawDistance
        let candidateA = CGPoint(
            x: baseX + height * dy / rawDistance,
            y: baseY - height * dx / rawDistance
        )
        let candidateB = CGPoint(
            x: baseX - height * dy / rawDistance,
            y: baseY + height * dx / rawDistance
        )
        return candidateA.y < candidateB.y ? candidateA : candidateB
    }

    private func chair(hip: CGPoint, unit: CGFloat) -> some View {
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
        .stroke(Color.khTextSecondary.opacity(0.28), style: StrokeStyle(lineWidth: 6 * unit, lineCap: .round))
    }

    private func head(hip: CGPoint, unit: CGFloat) -> some View {
        Circle()
            .fill(Color(hex: "#FFD7B5"))
            .frame(width: 47 * unit, height: 47 * unit)
            .overlay { Circle().stroke(Color.khBlueDark, lineWidth: 3 * unit) }
            .position(x: hip.x - 3.5 * unit, y: hip.y - 137.5 * unit)
    }

    private func torso(hip: CGPoint, unit: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 18 * unit, style: .continuous)
            .fill(Color.khMint)
            .frame(width: 37 * unit, height: 104 * unit)
            .overlay { RoundedRectangle(cornerRadius: 18 * unit).stroke(Color.khBlueDark, lineWidth: 4 * unit) }
            .position(x: hip.x - 3.5 * unit, y: hip.y - 63 * unit)
    }

    private func arm(hip: CGPoint, unit: CGFloat) -> some View {
        let shoulder = CGPoint(x: hip.x + 6 * unit, y: hip.y - 88 * unit)
        let elbow = CGPoint(x: hip.x + 18 * unit, y: hip.y - 44 * unit)
        let hand = CGPoint(x: hip.x + 39 * unit, y: hip.y - 8 * unit)
        let arm = Path { path in
            path.move(to: shoulder)
            path.addQuadCurve(to: elbow, control: CGPoint(x: hip.x + 13 * unit, y: hip.y - 66 * unit))
            path.addQuadCurve(to: hand, control: CGPoint(x: hip.x + 23 * unit, y: hip.y - 25 * unit))
        }
        return ZStack {
            arm.stroke(Color.khBlueDark, style: StrokeStyle(lineWidth: 14 * unit, lineCap: .round, lineJoin: .round))
            arm.stroke(Color(hex: "#FFD7B5"), style: StrokeStyle(lineWidth: 9 * unit, lineCap: .round, lineJoin: .round))
        }
    }

    private func floorLine(y: CGFloat, size: CGSize, unit: CGFloat) -> some View {
        Path { path in
            path.move(to: CGPoint(x: size.width * 0.39, y: y))
            path.addLine(to: CGPoint(x: size.width * 0.82, y: y))
        }
        .stroke(Color.khTextSecondary.opacity(0.16), style: StrokeStyle(lineWidth: 3 * unit, lineCap: .round))
    }

    private func slideTrace(from start: CGPoint, to end: CGPoint, unit: CGFloat) -> some View {
        ZStack {
            Path { path in
                path.move(to: start)
                path.addLine(to: end)
            }
            .stroke(Color.khMint.opacity(0.62), style: StrokeStyle(lineWidth: 3 * unit, lineCap: .round, dash: [3 * unit, 7 * unit]))

            Image(systemName: "arrow.left")
                .font(.system(size: 15 * unit, weight: .black))
                .foregroundStyle(Color.khMint)
                .position(start)
        }
    }

    private func outlinedLimb(from start: CGPoint, to end: CGPoint, width: CGFloat, outline: CGFloat, fill: Color) -> some View {
        ZStack {
            limb(from: start, to: end, width: width + outline * 2, color: .khBlueDark)
            limb(from: start, to: end, width: width, color: fill)
        }
    }

    private func foot(at ankle: CGPoint, unit: CGFloat, fill: Color) -> some View {
        RoundedRectangle(cornerRadius: 10 * unit, style: .continuous)
            .fill(fill)
            .frame(width: 54 * unit, height: 18 * unit)
            .overlay(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 3 * unit).fill(Color.khCareLime).frame(height: 5 * unit)
            }
            .overlay { RoundedRectangle(cornerRadius: 10 * unit).stroke(Color.khBlueDark, lineWidth: 3 * unit) }
            .position(x: ankle.x + 18 * unit, y: ankle.y)
    }

    private func limb(from start: CGPoint, to end: CGPoint, width: CGFloat, color: Color) -> some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
    }
}

#Preview("Heel Slide Preview") {
    NavigationStack {
        HeelSlidePreviewScreen(exercise: Exercise.placeholders[1])
    }
    .environmentObject(AngleService())
}

#Preview("Heel Slide Workout") {
    NavigationStack {
        HeelSlideScreen(exercise: Exercise.placeholders[1])
    }
    .environmentObject(AngleService())
}
