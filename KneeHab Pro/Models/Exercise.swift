import SwiftUI

struct Exercise: Identifiable, Hashable {
    enum Kind: String, Hashable {
        case seatedKneeExtension
        case heelSlide
        case quadSet
        case straightLegRaise
    }

    let id = UUID()
    let kind: Kind
    let name: String
    let subtitle: String
    let target: String
    let sets: Int
    let reps: Int
    let durationMinutes: Int
    let tint: Color
    let icon: String

    static let placeholders: [Exercise] = [
        Exercise(kind: .seatedKneeExtension, name: "Seated Knee Extension", subtitle: "Chair-based controlled raise", target: "Extension control", sets: 3, reps: 10, durationMinutes: 6, tint: .khBlue, icon: "chair.fill"),
        Exercise(kind: .heelSlide, name: "Heel Slide", subtitle: "Slow flexion range practice", target: "Flexion range", sets: 3, reps: 12, durationMinutes: 7, tint: .khMint, icon: "figure.roll"),
        Exercise(kind: .quadSet, name: "Quad Set", subtitle: "Gentle activation hold", target: "Quadriceps activation", sets: 4, reps: 8, durationMinutes: 8, tint: .khOrange, icon: "timer"),
        Exercise(kind: .straightLegRaise, name: "Straight Leg Raise", subtitle: "Strength and stability", target: "Hip and quad strength", sets: 3, reps: 8, durationMinutes: 5, tint: .khPurple, icon: "figure.strengthtraining.traditional")
    ]
}
