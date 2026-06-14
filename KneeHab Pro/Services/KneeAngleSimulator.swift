import Foundation
import Combine

@MainActor
final class KneeAngleSimulator: ObservableObject {
    @Published var angle: Double = 58
    @Published var isConnected = false
    @Published var isStreaming = false

    private var timer: Timer?
    private var phase: Double = 0

    func connectPlaceholderSensors() {
        isConnected = true
    }

    func start() {
        connectPlaceholderSensors()
        isStreaming = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    func stop() {
        isStreaming = false
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        phase += 0.035
        angle = 58 + (sin(phase) * 36) + (sin(phase * 0.43) * 7)
    }
}
