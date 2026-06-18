import Foundation

struct RehabProfile {
    let name: String
    let age: Int
    let surgery: String
    let operatedLeg: String
    let surgeryDate: Date
    let protocolName: String
    let week: Int
    let flexionGoal: Int
    let currentFlexion: Int
    let surgeonName: String
    let clinicianName: String
    let estimatedRecovery: String
    let totalWeeks: Int
    let nextAppointment: Date
    let sessionsCompleted: Int
    let sessionsTotal: Int
    let compliancePercent: Int

    static let placeholder = RehabProfile(
        name: "Demo Patient",
        age: 42,
        surgery: "Total Knee Replacement",
        operatedLeg: "Left",
        surgeryDate: Calendar.current.date(byAdding: .weekOfYear, value: -3, to: Date())!,
        protocolName: "Standard ROM Protocol",
        week: 3,
        flexionGoal: 120,
        currentFlexion: 89,
        surgeonName: "Dr. Sarah Chen",
        clinicianName: "James Wright PT",
        estimatedRecovery: "12 weeks",
        totalWeeks: 12,
        nextAppointment: Calendar.current.date(byAdding: .day, value: 4, to: Date())!,
        sessionsCompleted: 12,
        sessionsTotal: 15,
        compliancePercent: 80
    )
}
