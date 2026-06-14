import SwiftUI

struct ExerciseDetailView: View {
    @EnvironmentObject private var angleSource: KneeAngleSimulator
    let exercise: Exercise

    @State private var isRunning = false
    @State private var completedReps = 4

    var body: some View {
        ZStack {
            Color.khBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
                    ScreenHeader(title: exercise.name, subtitle: exercise.target, icon: exercise.icon)

                    KHCard(cornerRadius: 28) {
                        VStack(spacing: 16) {
                            SeatedLegVisualizer(angle: angleSource.angle)

                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Live movement")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.khTextSecondary)
                                    Text("\(Int(angleSource.angle.rounded())) deg")
                                        .font(.system(size: 38, weight: .black, design: .rounded))
                                        .foregroundStyle(Color.khTextPrimary)
                                }

                                Spacer()

                                StatusPill(text: isRunning ? "Running" : "Ready", icon: isRunning ? "play.fill" : "pause.fill", tint: isRunning ? .khGreen : .khOrange)
                            }
                        }
                    }

                    KHCard {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Set 1 progress")
                                    .font(.system(size: 21, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.khTextPrimary)
                                Spacer()
                                Text("\(completedReps) / \(exercise.reps)")
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.khTextSecondary)
                            }

                            ProgressView(value: Double(completedReps), total: Double(exercise.reps))
                                .tint(exercise.tint)
                                .scaleEffect(x: 1, y: 1.6, anchor: .center)

                            HStack(spacing: 10) {
                                sessionControl(title: isRunning ? "Pause" : "Start", icon: isRunning ? "pause.fill" : "play.fill", tint: exercise.tint, isFilled: true) {
                                    isRunning.toggle()
                                    if isRunning {
                                        angleSource.start()
                                    }
                                }

                                sessionControl(title: "Log rep", icon: "plus", tint: .khTextPrimary, isFilled: false) {
                                    completedReps = min(completedReps + 1, exercise.reps)
                                }
                            }
                        }
                    }

                    KHCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Coach notes")
                                .font(.system(size: 21, weight: .black, design: .rounded))
                                .foregroundStyle(Color.khTextPrimary)
                            noteRow("Move slowly and avoid sudden swinging.")
                            noteRow("Keep thigh sensor stable while the shin rotates.")
                            noteRow("Stop if pain level rises above the chosen threshold.")
                        }
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

    private func sessionControl(title: String, icon: String, tint: Color, isFilled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .black))
                Text(title)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .lineLimit(1)
            }
            .foregroundStyle(isFilled ? Color.white : Color.khTextPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                isFilled ? tint : Color.khSurfaceSecondary,
                in: RoundedRectangle(cornerRadius: 17, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }

    private func noteRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.khGreen)
            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.khTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview("Exercise Detail") {
    NavigationStack {
        ExerciseDetailView(exercise: Exercise.placeholders[0])
    }
    .environmentObject(KneeAngleSimulator())
}
