import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case dashboard
    case measurement
    case exercises
    case profile

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .dashboard: "Dashboard"
        case .measurement: "Measure"
        case .exercises: "Exercises"
        case .profile: "Profile"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: "square.grid.2x2.fill"
        case .measurement: "angle"
        case .exercises: "figure.strengthtraining.traditional"
        case .profile: "person.fill"
        }
    }
}
