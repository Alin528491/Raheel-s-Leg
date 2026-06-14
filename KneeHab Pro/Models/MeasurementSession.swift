import Foundation

struct MeasurementSession {
    var currentAngle: Double
    var maxFlexion: Double
    var minExtension: Double
    var targetFlexion: Double
    var duration: TimeInterval

    static let placeholder = MeasurementSession(
        currentAngle: 64,
        maxFlexion: 112,
        minExtension: 4,
        targetFlexion: 120,
        duration: 642
    )
}
