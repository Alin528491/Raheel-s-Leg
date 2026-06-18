import SwiftUI

struct ExerciseCanvasShell<Content: View>: View {
    let exercise: Exercise
    let dismiss: DismissAction
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    topBar

                    AppCard(cornerRadius: 30) {
                        content
                    }

                    AppCard(cornerRadius: 26) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Session target")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundStyle(Color.khTextPrimary)

                            HStack(spacing: 10) {
                                detail(icon: "repeat", text: "\(exercise.reps) reps")
                                detail(icon: "arrow.counterclockwise", text: "\(exercise.sets) sets")
                                detail(icon: "clock", text: "\(exercise.durationMinutes) min")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 6)
                .padding(.bottom, 34)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.84), in: Circle())
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.system(size: 23, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(exercise.target)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.45))
            }

            Spacer()

            Image(systemName: exercise.icon)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(exercise.tint)
                .frame(width: 46, height: 46)
                .background(exercise.tint.opacity(0.14), in: Circle())
        }
    }

    private func detail(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .black))
            Text(text)
                .font(.system(size: 12, weight: .black, design: .rounded))
        }
        .foregroundStyle(exercise.tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(exercise.tint.opacity(0.11), in: Capsule())
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color.khBackground,
                exercise.tint.opacity(0.13),
                Color(hex: "#F7FAEF")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
