import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var angleSource: KneeAngleSimulator
    @Binding var selectedTab: AppTab

    private let profile = RehabProfile.placeholder
    @State private var isCTAAnimating = false

    private let duoGreen = Color(hex: "#58CC02")
    private let duoBlue = Color(hex: "#2B7BE9")
    private let duoOrange = Color(hex: "#FF9600")
    private let duoBackground = Color(hex: "#F7F8FA")
    private let duoSurfaceSecondary = Color(hex: "#F0F2F5")
    private let duoTextPrimary = Color(hex: "#1A1D23")
    private let duoTextSecondary = Color(hex: "#6E7787")

    var body: some View {
        ZStack {
            duoBackground.ignoresSafeArea()
            dashboardAtmosphere.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    header
                    welcomeCard
                    targetCard
                    startSessionCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 28)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if !angleSource.isStreaming {
                angleSource.start()
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Dashboard")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(duoTextPrimary)

                Text("KneeHab Pro")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(duoTextSecondary)
            }

            Spacer()

            Image(systemName: "cross.case.fill")
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(duoGreen, in: Circle())
                .shadow(color: duoGreen.opacity(0.24), radius: 10, x: 0, y: 5)
        }
    }

    private var welcomeCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(welcomeGradient)

            Circle()
                .fill(Color.white.opacity(0.54))
                .frame(width: 190, height: 190)
                .blur(radius: 8)
                .offset(x: 190, y: -55)

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ready for rehab")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(duoBlue)

                        Text("Track today’s knee motion")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(duoTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 10) {
                            compactHeroPill(icon: "sensor.tag.radiowaves.forward.fill", text: "IMU mock", tint: duoGreen)
                            compactHeroPill(icon: "calendar", text: "Week \(profile.week)", tint: duoOrange)
                        }
                    }

                    Spacer(minLength: 0)

                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.72))
                            .frame(width: 84, height: 84)

                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 35, weight: .black))
                            .foregroundStyle(duoGreen)
                    }
                }
            }
            .padding(24)
        }
        .frame(minHeight: 208)
    }

    private var targetCard: some View {
        HStack(spacing: 12) {
            progressBubble(title: "Flexion", value: "112", goal: "\(profile.flexionGoal)", tint: duoBlue)
            progressBubble(title: "Extension", value: "4", goal: "\(profile.extensionGoal)", tint: duoGreen)
        }
    }

    private var startSessionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Start session")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.white.opacity(0.94))

                Spacer()

                Image(systemName: "play.fill")
                    .font(.system(size: 19, weight: .black))
                    .foregroundStyle(.white.opacity(0.92))
            }

            HStack(spacing: 10) {
                sessionButton(title: "Measure", icon: "angle", tab: .measurement, tint: duoBlue)
                sessionButton(title: "Exercises", icon: "figure.strengthtraining.traditional", tab: .exercises, tint: duoGreen)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [duoGreen, Color(hex: "#79D640"), duoBlue.opacity(0.92)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: duoGreen.opacity(0.22), radius: 16, x: 0, y: 8)
        .scaleEffect(isCTAAnimating ? 1.01 : 1.0)
        .task {
            guard !isCTAAnimating else { return }
            withAnimation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true)) {
                isCTAAnimating = true
            }
        }
    }

    private var dashboardAtmosphere: some View {
        VStack {
            HStack {
                Circle()
                    .fill(Color(hex: "#C6F8FF").opacity(0.55))
                    .frame(width: 190, height: 190)
                    .blur(radius: 35)
                    .offset(x: -70, y: -55)

                Spacer()

                Circle()
                    .fill(Color(hex: "#D7FFEE").opacity(0.72))
                    .frame(width: 170, height: 170)
                    .blur(radius: 32)
                    .offset(x: 60, y: -20)
            }

            Spacer()
        }
    }

    private var welcomeGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "#C9F4E4"),
                Color(hex: "#BEEBFF"),
                Color(hex: "#F4FBF7")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func compactHeroPill(icon: String, text: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .black))
            Text(text)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .lineLimit(1)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.68), in: Capsule())
    }

    private func progressBubble(title: String, value: String, goal: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(duoTextSecondary)
                Spacer()
                Image(systemName: "target")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(tint)
            }

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(duoTextPrimary)
                Text("/ \(goal) deg")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(duoTextSecondary)
            }

            ProgressView(value: min((Double(value) ?? 0) / max(Double(goal) ?? 1, 1), 1))
                .tint(tint)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.black.opacity(0.06), lineWidth: 1))
        .shadow(color: .black.opacity(0.045), radius: 12, x: 0, y: 5)
    }

    private func sessionButton(title: String, icon: String, tab: AppTab, tint: Color) -> some View {
        Button {
            selectedTab = tab
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .black))
                Text(title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .foregroundStyle(tint)
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview("Dashboard") {
    DashboardPreviewHost()
}

private struct DashboardPreviewHost: View {
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        DashboardView(selectedTab: $selectedTab)
            .environmentObject(KneeAngleSimulator())
    }
}
