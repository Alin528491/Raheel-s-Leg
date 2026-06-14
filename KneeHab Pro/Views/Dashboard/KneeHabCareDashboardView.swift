import SwiftUI

struct KneeHabCareDashboardView: View {
    @EnvironmentObject private var angleSource: KneeAngleSimulator
    @Binding var selectedTab: AppTab

    private let profile = RehabProfile.placeholder

    var body: some View {
        ZStack {
            tasklyBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    topBar
                    goalHero
                    readinessCard
                    todayPlanCard
                    startSessionCard
                }
                .frame(maxWidth: 440)
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 34)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if !angleSource.isStreaming {
                angleSource.start()
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.86), in: Circle())

                VStack(alignment: .leading, spacing: 1) {
                    Text("KneeHab Pro")
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)

                    Text("Week \(profile.week) protocol")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.48))
                }
            }
            .padding(.leading, 8)
            .padding(.trailing, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 14, x: 0, y: 8)

            Spacer()

            Image(systemName: "sensor.tag.radiowaves.forward.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 56, height: 56)
                .background(Color.white.opacity(0.84), in: Circle())
                .shadow(color: Color.black.opacity(0.06), radius: 14, x: 0, y: 8)
        }
        .padding(.top, 2)
    }

    private var goalHero: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 54, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#B8F85B").opacity(0.24),
                            Color(hex: "#A8C8FF").opacity(0.22),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )
                .frame(width: 330, height: 208)
                .rotationEffect(.degrees(-5))
                .offset(x: 58, y: 8)

            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .fill(Color.white.opacity(0.16))
                .frame(width: 250, height: 112)
                .rotationEffect(.degrees(-7))
                .offset(x: 44, y: 16)

            HStack(spacing: 8) {
                Capsule()
                    .fill(Color.black.opacity(0.12))
                    .frame(width: 18, height: 7)
                Capsule()
                    .fill(Color(hex: "#B8F85B").opacity(0.72))
                    .frame(width: 34, height: 7)
                Capsule()
                    .fill(Color.black.opacity(0.12))
                    .frame(width: 18, height: 7)
            }
            .offset(x: -6, y: -8)

            VStack(alignment: .leading, spacing: 10) {
                Text("Before measurement")
                    .font(.system(size: 21, weight: .semibold, design: .default))
                    .foregroundStyle(.black.opacity(0.58))

                Text("Calibrate sensors first")
                    .font(.system(size: 44, weight: .black, design: .default))
                    .foregroundStyle(.black)
                    .lineLimit(2)
                    .minimumScaleFactor(0.66)

                HStack(spacing: 10) {
                    heroPill(icon: "sensor.tag.radiowaves.forward.fill", text: "IMUs paired")
                    heroPill(icon: "scope", text: "Zero baseline needed")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
    }

    private var readinessCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Device readiness")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.black)

                Spacer()

                Text("CALIBRATE")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#DDF3FF"), in: Capsule())
            }

            VStack(spacing: 10) {
                readinessRow(icon: "1.circle.fill", title: "Thigh IMU", status: "Paired", tint: Color(hex: "#2B7BE9"), isComplete: true)
                readinessRow(icon: "2.circle.fill", title: "Shin IMU", status: "Paired", tint: Color(hex: "#58CC02"), isComplete: true)
                readinessRow(icon: "scope", title: "Zero calibration", status: "Required before live movement", tint: Color(hex: "#FF9600"), isComplete: false)
            }
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 34, style: .continuous))
        .shadow(color: Color.black.opacity(0.07), radius: 24, x: 0, y: 16)
    }

    private var todayPlanCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Today")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.black)

                Spacer()

                Text("Locked")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#E7FAD8"), in: Capsule())
            }

            HStack(spacing: 10) {
                dashboardMetric(icon: "target", value: "120", label: "Flexion goal", tint: Color(hex: "#58CC02"))
                dashboardMetric(icon: "arrow.left.and.right", value: "0", label: "Extension goal", tint: Color(hex: "#2B7BE9"))
                dashboardMetric(icon: "lock.fill", value: "--", label: "Live angle", tint: Color(hex: "#FF9600"))
            }
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 34, style: .continuous))
        .shadow(color: Color.black.opacity(0.07), radius: 24, x: 0, y: 16)
    }

    private var startSessionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Required first")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(.black.opacity(0.54))

                    Text("Calibrate")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }

                Spacer(minLength: 8)

                Circle()
                    .fill(Color.black)
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 19, weight: .black))
                            .foregroundStyle(.white)
                    }
            }

            HStack(spacing: 10) {
                careButton(title: "Zero baseline", icon: "scope", tab: .measurement)
                careButton(title: "Exercise locked", icon: "lock.fill", tab: .exercises)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#B8F85B"),
                    Color(hex: "#DDFB95")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 30, style: .continuous)
        )
        .overlay(alignment: .bottomLeading) {
            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 150, height: 150)
                .offset(x: -54, y: 86)
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color(hex: "#6DCC2E").opacity(0.22), radius: 22, x: 0, y: 14)
    }

    private var tasklyBackground: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#F7EED8"),
                        Color(hex: "#ECEBE2"),
                        Color(hex: "#DDE8F0")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                RoundedRectangle(cornerRadius: 64, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#BFD7FF"),
                                Color(hex: "#93B4FF")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: geo.size.width * 1.16, height: geo.size.height * 0.62)
                    .rotationEffect(.degrees(-8))
                    .offset(x: -geo.size.width * 0.04, y: geo.size.height * 0.48)

                RoundedRectangle(cornerRadius: 58, style: .continuous)
                    .fill(Color.white.opacity(0.18))
                    .frame(width: geo.size.width * 0.86, height: geo.size.height * 0.34)
                    .rotationEffect(.degrees(-10))
                    .offset(x: -geo.size.width * 0.24, y: geo.size.height * 0.68)
            }
        }
    }

    private func heroPill(icon: String, text: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .black))
            Text(text)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .lineLimit(1)
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.72), in: Capsule())
    }

    private func readinessRow(icon: String, title: String, status: String, tint: Color, isComplete: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(tint)
                .frame(width: 42, height: 42)
                .background(tint.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(.black)

                Text(status)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.54))
            }

            Spacer()

            Image(systemName: isComplete ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(isComplete ? Color(hex: "#58CC02") : Color(hex: "#FF9600"))
        }
        .padding(12)
        .background(Color(hex: "#F7F8FA"), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func dashboardMetric(icon: String, value: String, label: String, tint: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(tint)
                .frame(width: 42, height: 42)
                .background(tint.opacity(0.14), in: Circle())

            Text(value)
                .font(.system(size: 27, weight: .black, design: .rounded))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.76)

            Text(label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.black.opacity(0.54))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(hex: "#F7F8FA"), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func careButton(title: String, icon: String, tab: AppTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            HStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 17, weight: .black, design: .rounded))

                Image(systemName: icon)
                    .font(.system(size: 12, weight: .black))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.white.opacity(0.22), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Care Dashboard Theme") {
    KneeHabCareDashboardPreviewHost()
}

private struct KneeHabCareDashboardPreviewHost: View {
    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        KneeHabCareDashboardView(selectedTab: $selectedTab)
            .environmentObject(KneeAngleSimulator())
    }
}
