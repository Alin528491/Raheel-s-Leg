import SwiftUI

struct DashboardScreen: View {
    @EnvironmentObject private var angleSource: AngleService
    @Binding var selectedTab: MainTab
    @State private var isStartPulsing = false

    private let careLime = Color(hex: "#AAEE00")
    private let careGreen = Color(hex: "#44CC00")
    private let careBlue = Color(hex: "#9BC7FF")
    private let careMint = Color(hex: "#D9FAD0")
    private let carePeach = Color(hex: "#FFE2AC")
    private let careSky = Color(hex: "#D8F3FF")

    var body: some View {
        ZStack {
            careBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    topBar
                    heroBlock
                    recoveryStatusCard
                    startTodayCard
                    weeklyProgressCard
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
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.86), in: Circle())

                Text("KneeHab Pro")
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
            }
            .padding(.leading, 8)
            .padding(.trailing, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 14, x: 0, y: 8)

            Spacer()

            Image(systemName: "figure.walk")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 56, height: 56)
                .background(Color.white.opacity(0.84), in: Circle())
                .shadow(color: Color.black.opacity(0.06), radius: 14, x: 0, y: 8)
        }
    }

    private var heroBlock: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 54, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            careLime.opacity(0.38),
                            careSky.opacity(0.52),
                            careMint.opacity(0.40)
                        ],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )
                .frame(width: 318, height: 118)
                .rotationEffect(.degrees(-5))
                .offset(x: 58, y: 20)

            HStack(spacing: 8) {
                Capsule()
                    .fill(Color.black.opacity(0.12))
                    .frame(width: 18, height: 7)
                Capsule()
                    .fill(Color(hex: "#AAEE00").opacity(0.80))
                    .frame(width: 34, height: 7)
                Capsule()
                    .fill(Color.black.opacity(0.12))
                    .frame(width: 18, height: 7)
            }
            .offset(x: -4, y: 0)

            VStack(alignment: .leading, spacing: 8) {
                Text("Good Morning!")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundStyle(.black.opacity(0.58))

                Text("Ready for today’s plan?")
                    .font(.system(size: 35, weight: .black, design: .default))
                    .foregroundStyle(.black)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 132)
    }

    private var recoveryStatusCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text("Day")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                        Text("29")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                    }

                    Text("Early Recovery")
                        .font(.system(size: 21, weight: .black, design: .rounded))
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#2ED3A6").opacity(0.22), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.black.opacity(0.10), lineWidth: 7)
                        .frame(width: 78, height: 78)

                    Circle()
                        .trim(from: 0, to: 0.35)
                        .stroke(Color(hex: "#1E78FF"), style: StrokeStyle(lineWidth: 7, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 78, height: 78)

                    VStack(spacing: 0) {
                        Text("35%")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                        Text("Progress")
                            .font(.system(size: 9, weight: .black, design: .rounded))
                    }
                }
            }

            HStack(spacing: 10) {
                statusPill(icon: "target", text: "Goal: 110 deg", tint: Color(hex: "#FF9F2E"))
                statusPill(icon: "calendar", text: "Phase 2 of 5", tint: Color(hex: "#1E78FF"))
            }
        }
        .foregroundStyle(.black)
        .padding(20)
        .background(Color.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.72), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.07), radius: 24, x: 0, y: 16)
    }

    private var startTodayCard: some View {
        Button {
            selectedTab = .measurement
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Today’s Activity")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(.black.opacity(0.50))

                        Text("Start today's activity")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(.black)
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)
                    }

                    Spacer()

                    pulsingStartButton
                }

                HStack(spacing: 10) {
                    Image(systemName: "scope")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(.black)

                    Text("Calibration starts first")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(.black.opacity(0.62))

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 13)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.70), in: Capsule())
            }
            .padding(18)
            .background(
                LinearGradient(
                    colors: [careLime, Color(hex: "#CCFF44"), Color(hex: "#DEFF88")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 34, style: .continuous)
            )
            .overlay(alignment: .bottomLeading) {
                Circle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 150, height: 150)
                    .offset(x: -54, y: 86)
            }
            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            .shadow(color: careGreen.opacity(0.26), radius: 26, x: 0, y: 18)
        }
        .buttonStyle(.plain)
        .task {
            guard !isStartPulsing else { return }
            withAnimation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true)) {
                isStartPulsing = true
            }
        }
    }

    private var pulsingStartButton: some View {
        ZStack {
            Circle()
                .fill(careLime.opacity(isStartPulsing ? 0.0 : 0.42))
                .frame(width: 86, height: 86)
                .scaleEffect(isStartPulsing ? 1.22 : 0.86)

            Circle()
                .fill(Color.white.opacity(0.92))
                .frame(width: 66, height: 66)
                .shadow(color: careGreen.opacity(0.28), radius: 14, x: 0, y: 8)

            VStack(spacing: 1) {
                Image(systemName: "play.fill")
                    .font(.system(size: 17, weight: .black))
                Text("START")
                    .font(.system(size: 10, weight: .black, design: .rounded))
            }
            .foregroundStyle(.black)
        }
        .frame(width: 86, height: 86)
        .accessibilityLabel("Start today's activity")
    }

    private var weeklyProgressCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("This Week’s Progress")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.black)

                Spacer()

                Text("4/7 days")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(careBlue.opacity(0.40), in: Capsule())
            }

            HStack(alignment: .bottom, spacing: 10) {
                weekBar(day: "Mon", value: "95", height: 46, tint: careGreen, isDone: true)
                weekBar(day: "Tue", value: "102", height: 48, tint: careGreen, isDone: true)
                weekBar(day: "Wed", value: "89", height: 43, tint: Color.black.opacity(0.12), isDone: false)
                weekBar(day: "Thu", value: "110", height: 50, tint: careGreen, isDone: true)
                weekBar(day: "Fri", value: "-", height: 17, tint: Color.black.opacity(0.10), isDone: false)
                weekBar(day: "Sat", value: "-", height: 17, tint: Color.black.opacity(0.10), isDone: false)
                weekBar(day: "Sun", value: "-", height: 17, tint: Color.black.opacity(0.10), isDone: false)
            }

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("110 deg")
                        .font(.system(size: 31, weight: .black, design: .rounded))
                        .foregroundStyle(careGreen)
                    Text("Week Best")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.54))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text("+8 deg")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                    Text("vs Last Week")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.54))
                }
            }
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 34, style: .continuous))
        .shadow(color: Color.black.opacity(0.07), radius: 24, x: 0, y: 16)
    }

    private var careBackground: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#FFF4D9"),
                        Color(hex: "#F8F0DE"),
                        Color(hex: "#DCEFFF")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                RoundedRectangle(cornerRadius: 64, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#B9E1FF"),
                                Color(hex: "#8FB8FF")
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

    private func statusPill(icon: String, text: String, tint: Color) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(tint)
            Text(text)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .lineLimit(1)
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(tint.opacity(0.15), in: Capsule())
    }

    private func weekBar(day: String, value: String, height: CGFloat, tint: Color, isDone: Bool) -> some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(tint)
                .frame(width: 31, height: height)

            Text(value == "-" ? "-" : "\(value) deg")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(isDone ? careGreen : Color.black.opacity(0.42))
                .lineLimit(1)
                .minimumScaleFactor(0.66)

            Text(day)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.black.opacity(0.48))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Dashboard") {
    DashboardPreviewHost()
}

private struct DashboardPreviewHost: View {
    @State private var selectedTab: MainTab = .dashboard

    var body: some View {
        DashboardScreen(selectedTab: $selectedTab)
            .environmentObject(AngleService())
    }
}
