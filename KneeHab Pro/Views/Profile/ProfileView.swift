import SwiftUI

struct ProfileView: View {
    private let profile = RehabProfile.placeholder

    var body: some View {
        ZStack {
            Color.khBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
                    ScreenHeader(title: "Profile", subtitle: "Patient and rehab protocol", icon: "person.fill")

                    KHCard(cornerRadius: 28) {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.khBlue, .khMint], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 92, height: 92)

                                Text("DP")
                                    .font(.system(size: 31, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                            }

                            VStack(spacing: 5) {
                                Text(profile.name)
                                    .font(.system(size: 25, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.khTextPrimary)
                                Text(profile.surgery)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.khTextSecondary)
                            }

                            HStack(spacing: 10) {
                                StatusPill(text: "Week \(profile.week)", icon: "calendar", tint: .khBlue)
                                StatusPill(text: "Demo protocol", icon: "doc.text.fill", tint: .khMint)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    HStack(spacing: 12) {
                        MetricCard(title: "Flexion goal", value: "\(profile.flexionGoal)", unit: "deg", icon: "target", tint: .khBlue)
                        MetricCard(title: "Extension goal", value: "\(profile.extensionGoal)", unit: "deg", icon: "scope", tint: .khMint)
                    }

                    settingsCard
                    deviceCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var settingsCard: some View {
        KHCard {
            VStack(alignment: .leading, spacing: 13) {
                Text("Rehab details")
                    .font(.system(size: 21, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)

                profileRow(label: "Protocol", value: profile.protocolName, icon: "list.clipboard.fill", tint: .khBlue)
                profileRow(label: "Clinician", value: "Not assigned", icon: "stethoscope", tint: .khMint)
                profileRow(label: "Pain limit", value: "Placeholder: 5 / 10", icon: "heart.text.square.fill", tint: .khOrange)
            }
        }
    }

    private var deviceCard: some View {
        KHCard {
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    Text("Sensors")
                        .font(.system(size: 21, weight: .black, design: .rounded))
                        .foregroundStyle(Color.khTextPrimary)
                    Spacer()
                    StatusPill(text: "Future IMU", icon: "sensor.tag.radiowaves.forward.fill", tint: .khGreen)
                }

                profileRow(label: "Thigh IMU", value: "Placeholder device slot", icon: "1.circle.fill", tint: .khBlue)
                profileRow(label: "Shin IMU", value: "Placeholder device slot", icon: "2.circle.fill", tint: .khMint)
            }
        }
    }

    private func profileRow(label: String, value: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(tint.opacity(0.13), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.khTextSecondary)
                Text(value)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)
            }

            Spacer()
        }
    }
}

#Preview("Profile") {
    ProfileView()
}
