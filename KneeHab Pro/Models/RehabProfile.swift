import Foundation

struct RehabProfile {
    let name: String
    let surgery: String
    let protocolName: String
    let week: Int
    let flexionGoal: Int
    let extensionGoal: Int

    static let placeholder = RehabProfile(
        name: "Demo Patient",
        surgery: "Post-op knee rehab",
        protocolName: "Standard ROM protocol",
        week: 3,
        flexionGoal: 120,
        extensionGoal: 0
    )
}
