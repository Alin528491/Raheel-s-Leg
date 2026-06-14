import SwiftUI

struct ExerciseListView: View {
    @EnvironmentObject private var angleSource: KneeAngleSimulator
    private let exercises = Exercise.placeholders

    var body: some View {
        ZStack {
            Color.khBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
                    ScreenHeader(title: "Exercises", subtitle: "Placeholder rehab workout library", icon: "figure.strengthtraining.traditional")

                    KHCard(cornerRadius: 28) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Guided movement")
                                        .font(.system(size: 23, weight: .black, design: .rounded))
                                        .foregroundStyle(Color.khTextPrimary)
                                    Text("The leg visual can mirror IMU angle during chair-based exercises.")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color.khTextSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                            }

                            SeatedLegVisualizer(angle: angleSource.angle, showTrace: true)
                        }
                    }

                    ForEach(exercises) { exercise in
                        NavigationLink {
                            ExerciseDetailView(exercise: exercise)
                        } label: {
                            exerciseRow(exercise)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            angleSource.start()
        }
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        HStack(spacing: 14) {
            Image(systemName: exercise.icon)
                .font(.system(size: 19, weight: .black))
                .foregroundStyle(exercise.tint)
                .frame(width: 52, height: 52)
                .background(exercise.tint.opacity(0.13), in: Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text(exercise.name)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)
                Text(exercise.subtitle)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.khTextSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {
                Text("\(exercise.sets)x\(exercise.reps)")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(Color.khTextSecondary)
            }
        }
        .padding(15)
        .background(Color.khSurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.khBorder, lineWidth: 1))
    }
}

#Preview("Exercises") {
    NavigationStack {
        ExerciseListView()
    }
    .environmentObject(KneeAngleSimulator())
}
