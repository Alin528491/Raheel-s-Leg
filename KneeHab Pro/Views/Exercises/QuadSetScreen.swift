import SwiftUI

struct QuadSetScreen: View {
    @Environment(\.dismiss) private var dismiss
    let exercise: Exercise

    var body: some View {
        ExerciseCanvasShell(exercise: exercise, dismiss: dismiss) {
            VStack(spacing: 16) {
                Image(systemName: "timer")
                    .font(.system(size: 54, weight: .black))
                    .foregroundStyle(exercise.tint)
                    .frame(width: 112, height: 112)
                    .background(exercise.tint.opacity(0.14), in: Circle())

                VStack(spacing: 6) {
                    Text("Quad set canvas")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(Color.khTextPrimary)
                    Text("Build activation holds, timers, and squeeze feedback here.")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.khTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
    }
}

#Preview("Quad Set") {
    NavigationStack {
        QuadSetScreen(exercise: Exercise.placeholders[2])
    }
}
