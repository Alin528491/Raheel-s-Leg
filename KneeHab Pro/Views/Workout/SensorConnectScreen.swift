import SwiftUI

struct SensorConnectScreen: View {
    @EnvironmentObject private var angleSource: AngleService
    @State private var selectedDeviceID: UUID?

    var onContinue: () -> Void = {}

    private let careLime = Color(hex: "#AAEE00")
    private let careGreen = Color(hex: "#44CC00")
    private let careSky = Color(hex: "#D8F3FF")

    private var selectedDevice: SensorDevice? {
        guard let selectedDeviceID else { return nil }
        return angleSource.availableDevices.first { $0.id == selectedDeviceID }
    }

    var body: some View {
        ZStack {
            connectBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    topBar
                    titleBlock
                    deviceList
                    setupInstructions
                }
                .frame(maxWidth: 440)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, angleSource.isConnected || selectedDevice != nil ? 170 : 34)
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomPanel
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if !angleSource.isStreaming {
                angleSource.start()
            }
        }
        .onChange(of: angleSource.isConnected) { _, isConnected in
            if isConnected {
                selectedDeviceID = nil
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "sensor.tag.radiowaves.forward.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.86), in: Circle())

                VStack(alignment: .leading, spacing: 1) {
                    Text("KneeHab Pro")
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)

                    Text("Workout sensors")
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

            StatusPill(
                text: angleSource.isConnected ? "Ready" : "Pairing",
                icon: angleSource.isConnected ? "checkmark" : "antenna.radiowaves.left.and.right",
                tint: angleSource.isConnected ? careGreen : Color.khBlue
            )
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 54, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                careLime.opacity(0.32),
                                careSky.opacity(0.58),
                                Color.white.opacity(0.10)
                            ],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        )
                    )
                    .frame(width: 320, height: 148)
                    .rotationEffect(.degrees(-5))
                    .offset(x: 54, y: 14)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Select Your Device")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .lineLimit(2)
                        .minimumScaleFactor(0.70)

                    Text("Tap the shin and thigh sensors, then connect each one.")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.52))
                        .fixedSize(horizontal: false, vertical: true)

                    StatusPill(
                        text: angleSource.statusText,
                        icon: "waveform.path.ecg",
                        tint: angleSource.isConnected ? careGreen : Color.khOrange
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 166)
        }
    }

    private var deviceList: some View {
        VStack(spacing: 12) {
            deviceRow(for: .shin)
            deviceRow(for: .thigh)
        }
    }

    private func deviceRow(for placement: SensorPlacement) -> some View {
        let device = device(for: placement)
        let isConnected = device?.isConnected ?? false
        let isSelected = selectedDeviceID == device?.id

        return Button {
            if let device {
                selectedDeviceID = device.id
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isConnected ? Color(hex: "#DBF8E7") : Color(hex: "#E8F6FF"))
                        .frame(width: 56, height: 56)

                    Image(systemName: isConnected ? "checkmark.circle.fill" : "sensor.tag.radiowaves.forward.fill")
                        .font(.system(size: 25, weight: .black))
                        .foregroundStyle(isConnected ? Color.khMint : Color.khBlue)
                }

                VStack(alignment: .leading, spacing: 7) {
                    Text(placement.title)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(Color.khTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text(device == nil ? "Searching..." : placement.subtitle)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.khTextSecondary)

                    HStack(spacing: 12) {
                        sensorMeta(
                            icon: "wifi",
                            text: device.map { "Signal \($0.signalPercent)%" } ?? "Signal --",
                            tint: device == nil ? Color.khTextSecondary : Color.khMint
                        )

                        sensorMeta(
                            icon: "battery.75percent",
                            text: "Battery --",
                            tint: Color.khMint
                        )
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: isConnected ? "checkmark.circle.fill" : "chevron.right")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(isConnected ? Color.khMint : Color.khBlue)
            }
            .padding(18)
            .background(Color.white.opacity(0.96), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(isSelected ? Color.khBlue : Color.khBorder, lineWidth: isSelected ? 2 : 1)
            }
            .shadow(color: Color.black.opacity(0.06), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .disabled(device == nil)
    }

    private func sensorMeta(icon: String, text: String, tint: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(tint)

            Text(text)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Color.khTextSecondary)
                .lineLimit(1)
        }
    }

    private var setupInstructions: some View {
        AppCard(cornerRadius: 28) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Setup Instructions")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)

                instruction(number: "1", text: "Attach the thigh sensor above the knee.")
                instruction(number: "2", text: "Attach the shin sensor below the knee.")
                instruction(number: "3", text: "Select each sensor and connect it.")
            }
        }
    }

    private func instruction(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Color.khBlue, in: Circle())

            Text(text)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.khTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var bottomPanel: some View {
        if angleSource.isConnected {
            readyPanel
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        } else if let selectedDevice {
            selectedDevicePanel(selectedDevice)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
    }

    private var readyPanel: some View {
        VStack(spacing: 12) {
            Capsule()
                .fill(Color.black.opacity(0.12))
                .frame(width: 46, height: 5)

            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(Color.khMint)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Sensors Connected")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(Color.khTextPrimary)
                    Text("Thigh and shin are ready for workout tracking.")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.khTextSecondary)
                }

                Spacer(minLength: 0)
            }

            Button {
                onContinue()
            } label: {
                Text("Continue")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.khBlue, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 22, x: 0, y: 10)
    }

    private func selectedDevicePanel(_ device: SensorDevice) -> some View {
        VStack(spacing: 14) {
            Capsule()
                .fill(Color.black.opacity(0.12))
                .frame(width: 46, height: 5)

            HStack(spacing: 14) {
                Image(systemName: device.isConnected ? "checkmark.circle.fill" : "sensor.tag.radiowaves.forward.fill")
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(device.isConnected ? Color.khMint : Color.khBlue)
                    .frame(width: 54, height: 54)
                    .background(Color(hex: "#E8F6FF"), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(device.placement.title)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(Color.khTextPrimary)

                    Text("Device ID: \(device.shortID)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.khTextSecondary)
                }

                Spacer(minLength: 0)
            }

            Button {
                angleSource.connect(to: device.id)
            } label: {
                Label(
                    device.isConnected ? "Connected" : "Connect to \(device.placement.title)",
                    systemImage: device.isConnected ? "checkmark" : "antenna.radiowaves.left.and.right"
                )
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(device.isConnected ? Color.khMint : Color.khBlue, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(device.isConnected)

            Button {
                selectedDeviceID = nil
            } label: {
                Text("Cancel")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.khSurfaceSecondary.opacity(0.72), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 22, x: 0, y: 10)
    }

    private func device(for placement: SensorPlacement) -> SensorDevice? {
        angleSource.availableDevices.first { $0.placement == placement }
    }

    private var connectBackground: some View {
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
                    .fill(LinearGradient(
                        colors: [Color(hex: "#B9E1FF"), Color(hex: "#8FB8FF")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: geo.size.width * 1.16, height: geo.size.height * 0.58)
                    .rotationEffect(.degrees(-8))
                    .offset(x: -geo.size.width * 0.04, y: geo.size.height * 0.50)
            }
        }
    }
}

#Preview("Sensor Connect") {
    SensorConnectScreen()
        .environmentObject(AngleService())
}
