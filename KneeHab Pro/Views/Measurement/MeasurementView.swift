import SwiftUI

struct MeasurementView: View {
    @EnvironmentObject private var angleSource: KneeAngleSimulator
    @State private var isRecording = false
    @State private var session = MeasurementSession.placeholder

    var body: some View {
        ZStack {
            Color.khBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
                    ScreenHeader(title: "Measurement", subtitle: "Hospital-style knee ROM placeholder", icon: "angle")

                    KHCard(cornerRadius: 28) {
                        VStack(spacing: 16) {
                            SeatedLegVisualizer(angle: angleSource.angle)

                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Live knee angle")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.khTextSecondary)
                                    Text("\(Int(angleSource.angle.rounded())) deg")
                                        .font(.system(size: 43, weight: .black, design: .rounded))
                                        .foregroundStyle(Color.khTextPrimary)
                                        .contentTransition(.numericText())
                                }

                                Spacer()

                                Button {
                                    isRecording.toggle()
                                    if isRecording {
                                        angleSource.start()
                                    }
                                } label: {
                                    Image(systemName: isRecording ? "stop.fill" : "record.circle")
                                        .font(.system(size: 23, weight: .black))
                                        .foregroundStyle(.white)
                                        .frame(width: 62, height: 62)
                                        .background(isRecording ? Color.khRed : Color.khBlue, in: Circle())
                                        .shadow(color: (isRecording ? Color.khRed : Color.khBlue).opacity(0.28), radius: 14, x: 0, y: 6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    HStack(spacing: 12) {
                        MetricCard(title: "Max flexion", value: "\(Int(session.maxFlexion))", unit: "deg", icon: "arrow.down.forward", tint: .khBlue)
                        MetricCard(title: "Extension", value: "\(Int(session.minExtension))", unit: "deg", icon: "arrow.up.backward", tint: .khMint)
                    }

                    protocolCard
                    sensorCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            angleSource.start()
        }
    }

    private var protocolCard: some View {
        KHCard {
            VStack(alignment: .leading, spacing: 13) {
                Text("ROM capture flow")
                    .font(.system(size: 21, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)

                measurementStep(number: "1", title: "Sit in chair", detail: "Thigh IMU fixed above knee, shin IMU fixed below knee.")
                measurementStep(number: "2", title: "Zero extension", detail: "Hold the leg in the starting position and mark baseline.")
                measurementStep(number: "3", title: "Move slowly", detail: "Raise and lower the lower leg while the app records min and max.")
            }
        }
    }

    private var sensorCard: some View {
        KHCard {
            HStack(spacing: 14) {
                Image(systemName: "sensor.tag.radiowaves.forward.fill")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(Color.khGreen)
                    .frame(width: 50, height: 50)
                    .background(Color.khGreen.opacity(0.13), in: Circle())

                VStack(alignment: .leading, spacing: 5) {
                    Text("IMU connection placeholder")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(Color.khTextPrimary)
                    Text("Ready for thigh + shin sensor pipeline.")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.khTextSecondary)
                }

                Spacer()
                StatusPill(text: "Mock", icon: "waveform.path.ecg", tint: .khOrange)
            }
        }
    }

    private func measurementStep(number: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 27, height: 27)
                .background(Color.khBlue, in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)
                Text(detail)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.khTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview("Measurement") {
    MeasurementView()
        .environmentObject(KneeAngleSimulator())
}
