import SwiftUI

struct Exercise: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let subtitle: String
    let target: String
    let sets: Int
    let reps: Int
    let tint: Color
    let icon: String

    static let placeholders: [Exercise] = [
        Exercise(name: "Seated Knee Extension", subtitle: "Chair-based controlled raise", target: "Extension control", sets: 3, reps: 10, tint: .khBlue, icon: "chair.fill"),
        Exercise(name: "Heel Slide", subtitle: "Slow flexion range practice", target: "Flexion range", sets: 3, reps: 12, tint: .khMint, icon: "arrow.left.and.right"),
        Exercise(name: "Quad Set", subtitle: "Gentle activation hold", target: "Quadriceps activation", sets: 4, reps: 8, tint: .khOrange, icon: "timer"),
        Exercise(name: "Straight Leg Raise", subtitle: "Strength placeholder", target: "Hip and quad strength", sets: 3, reps: 8, tint: .khPurple, icon: "figure.strengthtraining.traditional")
    ]
}
