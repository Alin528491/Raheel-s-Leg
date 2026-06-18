import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject private var angleSource: AngleService

    private let profile = RehabProfile.placeholder

    private var recoveryProgress: Double {
        guard profile.totalWeeks > 0 else { return 0 }
        return min(Double(profile.week) / Double(profile.totalWeeks), 1)
    }

    private var initials: String {
        profile.name
            .split(separator: " ")
            .compactMap(\.first)
            .prefix(2)
            .map(String.init)
            .joined()
    }

    var body: some View {
        ZStack {
            CareBackground()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    topBar
                    identityHero
                    recoveryMetrics
                    treatmentDetails
                    sensorStatus
                }
                .frame(maxWidth: 440)
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 34)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.86), in: Circle())

                VStack(alignment: .leading, spacing: 1) {
                    Text("Profile")
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)

                    Text("Recovery overview")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.48))
                }
            }
            .padding(.leading, 8)
            .padding(.trailing, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 14, x: 0, y: 8)

            Spacer()

            Image(systemName: "cross.case.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 56, height: 56)
                .background(Color.white.opacity(0.84), in: Circle())
                .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 8)
        }
    }

    private var identityHero: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 15) {
                Text(initials)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 66, height: 66)
                    .background(Color.black, in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text("\(profile.age) years  ·  \(profile.operatedLeg) knee")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.56))
                }

                Spacer(minLength: 6)

                VStack(spacing: 0) {
                    Text("\(profile.week)")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                    Text("WEEK")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                }
                .foregroundStyle(.black)
                .frame(width: 58, height: 58)
                .background(Color.white.opacity(0.78), in: Circle())
            }

            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    Text(profile.surgery)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Spacer()

                    Text("\(Int(recoveryProgress * 100))%")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.58))

                        Capsule()
                            .fill(Color.black)
                            .frame(width: geometry.size.width * recoveryProgress)
                    }
                }
                .frame(height: 9)

                HStack {
                    Text("Surgery \(profile.surgeryDate.formatted(date: .abbreviated, time: .omitted))")
                    Spacer()
                    Text("\(profile.totalWeeks) week plan")
                }
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.black.opacity(0.50))
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.khCareLime, Color(hex: "#D7FF72"), Color.khCareSky],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 30, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.56), lineWidth: 1)
        }
        .shadow(color: Color.khCareGreen.opacity(0.18), radius: 22, x: 0, y: 14)
    }

    private var recoveryMetrics: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading("Recovery", icon: "chart.line.uptrend.xyaxis")

            HStack(spacing: 0) {
                metric(value: "\(profile.currentFlexion)°", label: "Flexion", tint: .khBlue)
                metricDivider
                metric(value: "\(profile.compliancePercent)%", label: "Adherence", tint: .khCareGreen)
                metricDivider
                metric(value: "\(profile.sessionsCompleted)/\(profile.sessionsTotal)", label: "Sessions", tint: .khOrange)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Flexion goal")
                    Spacer()
                    Text("\(profile.flexionGoal)°")
                }
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(Color.khTextSecondary)

                progressBar(
                    value: min(Double(profile.currentFlexion) / Double(max(profile.flexionGoal, 1)), 1),
                    tint: .khBlue
                )
            }
        }
        .carePanel()
    }

    private var treatmentDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            sectionHeading("Treatment", icon: "cross.case.fill")
                .padding(.bottom, 8)

            detailRow(icon: "list.clipboard.fill", title: "Protocol", value: profile.protocolName, tint: .khBlue)
            rowDivider
            detailRow(icon: "stethoscope", title: "Clinician", value: profile.clinicianName, tint: .khMint)
            rowDivider
            detailRow(icon: "calendar.badge.clock", title: "Next appointment", value: profile.nextAppointment.formatted(date: .abbreviated, time: .omitted), tint: .khOrange)
            rowDivider
            detailRow(icon: "clock.fill", title: "Estimated recovery", value: profile.estimatedRecovery, tint: .khPurple)
        }
        .carePanel()
    }

    private var sensorStatus: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                sectionHeading("Sensors", icon: "sensor.tag.radiowaves.forward.fill")
                Spacer()
                StatusPill(
                    text: angleSource.isConnected ? "Ready" : "Not ready",
                    icon: angleSource.isConnected ? "checkmark.circle.fill" : "exclamationmark.circle.fill",
                    tint: angleSource.isConnected ? .khCareGreen : .khOrange
                )
            }
            .padding(.bottom, 8)

            sensorRow(name: "KP1 Thigh", location: "Above the knee", isConnected: angleSource.thighConnected)
            rowDivider
            sensorRow(name: "KP1 Shin", location: "Below the knee", isConnected: angleSource.shinConnected)
        }
        .carePanel()
    }

    private func sectionHeading(_ title: String, icon: String) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(.black)
                .frame(width: 32, height: 32)
                .background(Color.khCareLime.opacity(0.58), in: Circle())

            Text(title)
                .font(.system(size: 21, weight: .black, design: .rounded))
                .foregroundStyle(Color.khTextPrimary)
        }
    }

    private func metric(value: String, label: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 23, weight: .black, design: .rounded))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Color.khTextSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private var metricDivider: some View {
        Rectangle()
            .fill(Color.khBorder)
            .frame(width: 1, height: 44)
    }

    private var rowDivider: some View {
        Divider()
            .overlay(Color.khBorder)
            .padding(.leading, 50)
    }

    private func detailRow(icon: String, title: String, value: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(tint.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.khTextSecondary)

                Text(value)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
    }

    private func sensorRow(name: String, location: String, isConnected: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "sensor.tag.radiowaves.forward.fill")
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(isConnected ? Color.khCareGreen : Color.khTextSecondary)
                .frame(width: 38, height: 38)
                .background((isConnected ? Color.khCareGreen : Color.khSurfaceSecondary).opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)

                Text(location)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.khTextSecondary)
            }

            Spacer()

            Text(isConnected ? "Connected" : "Disconnected")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(isConnected ? Color.khCareGreen : Color.khTextSecondary)
        }
        .padding(.vertical, 8)
    }

    private func progressBar(value: Double, tint: Color) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.khSurfaceSecondary)

                Capsule()
                    .fill(tint)
                    .frame(width: geometry.size.width * value)
            }
        }
        .frame(height: 8)
    }
}

private extension View {
    func carePanel() -> some View {
        padding(18)
            .background(Color.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.72), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 12)
    }
}

#Preview("Profile") {
    ProfileScreen()
        .environmentObject(AngleService())
}
