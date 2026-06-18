import SwiftUI

struct ExerciseDetailScreen: View {
    let exercise: Exercise

    var body: some View {
        switch exercise.kind {
        case .seatedKneeExtension:
            SeatedKneeExtensionScreen(exercise: exercise)
        case .heelSlide:
            HeelSlideScreen(exercise: exercise)
        case .quadSet:
            QuadSetScreen(exercise: exercise)
        case .straightLegRaise:
            StraightLegRaiseScreen(exercise: exercise)
        }
    }
}

#Preview("Exercise Router") {
    NavigationStack {
        ExerciseDetailScreen(exercise: Exercise.placeholders[0])
    }
    .environmentObject(AngleService())
}
