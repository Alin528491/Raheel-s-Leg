import SwiftUI

struct ExerciseListScreen: View {
    private let exercises = Exercise.placeholders
    private let careLime = Color(hex: "#AAEE00")
    private let careGreen = Color(hex: "#44CC00")

    private var totalMinutes: Int { exercises.reduce(0) { $0 + $1.durationMinutes } }
    private var totalSets: Int { exercises.reduce(0) { $0 + $1.sets } }

    var body: some View {
        ZStack {
            exerciseBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    topBar
                    heroCard
                    sectionLabel("Today's exercises")
                    ForEach(exercises) { exercise in
                        NavigationLink {
                            if exercise.kind == .seatedKneeExtension {
                                SeatedKneeExtensionPreviewScreen(exercise: exercise)
                            } else if exercise.kind == .heelSlide {
                                HeelSlidePreviewScreen(exercise: exercise)
                            } else {
                                WorkoutCalibrationScreen(exercise: exercise)
                            }
                        } label: {
                            exerciseCard(exercise)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 34)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 38, height: 38)
                    .background(Color.white.opacity(0.86), in: Circle())
                Text("Exercises")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
            }
            .padding(.leading, 8)
            .padding(.trailing, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 14, x: 0, y: 8)
            Spacer()
        }
        .padding(.top, 4)
    }

    // MARK: - Hero Card

    private var heroCard: some View {
        ZStack(alignment: .bottomTrailing) {
            // Decorative blob
            RoundedRectangle(cornerRadius: 54, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color.white.opacity(0.28), Color.white.opacity(0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 260, height: 100)
                .rotationEffect(.degrees(-8))
                .offset(x: 40, y: 18)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Ready to move?")
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(.black.opacity(0.55))
                    Text("Today's session")
                        .font(.system(size: 34, weight: .black, design: .default))
                        .foregroundStyle(.black)
                        .lineLimit(2)
                }

                HStack(spacing: 10) {
                    heroStat(value: "\(exercises.count)", label: "moves", icon: "list.bullet")
                    heroDivider()
                    heroStat(value: "\(totalSets)", label: "sets", icon: "arrow.counterclockwise")
                    heroDivider()
                    heroStat(value: "~\(totalMinutes)", label: "min", icon: "clock.fill")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .fixedSize(horizontal: true, vertical: false)
                .background(Color.white.opacity(0.70), in: Capsule())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                LinearGradient(
                    colors: [careLime, Color(hex: "#CCFF44"), Color(hex: "#DEFF88")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 34, style: .continuous)
            )
            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            .shadow(color: careGreen.opacity(0.26), radius: 26, x: 0, y: 18)
        }
    }

    private func heroStat(value: String, label: String, icon: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(.black.opacity(0.55))
            Text(value)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(.black)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.black.opacity(0.55))
                .lineLimit(1)
        }
        .fixedSize()
    }

    private func heroDivider() -> some View {
        Capsule()
            .fill(Color.black.opacity(0.15))
            .frame(width: 1, height: 16)
    }

    // MARK: - Section Label

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .black, design: .rounded))
            .foregroundStyle(.black.opacity(0.40))
            .textCase(.uppercase)
            .tracking(1.2)
            .padding(.top, 2)
    }

    // MARK: - Exercise Card

    private func exerciseCard(_ exercise: Exercise) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Image(systemName: exercise.icon)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(exercise.tint)
                    .frame(width: 58, height: 58)
                    .background(exercise.tint.opacity(0.13), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                    Text(exercise.subtitle)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.black.opacity(0.42))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(.black.opacity(0.22))
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 14)

            Divider().opacity(0.08).padding(.horizontal, 18)

            HStack(spacing: 8) {
                detailTag(icon: "clock", text: "\(exercise.durationMinutes) min", tint: exercise.tint)
                detailTag(icon: "arrow.counterclockwise", text: "\(exercise.sets) sets", tint: exercise.tint)
                detailTag(icon: "repeat", text: "\(exercise.reps) reps", tint: exercise.tint)
                Spacer()
                Text(exercise.target)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.30))
                    .lineLimit(1)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
        }
        .background(Color.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 10)
    }

    private func detailTag(icon: String, text: String, tint: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(tint)
            Text(text)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(.black.opacity(0.65))
                .lineLimit(1)
        }
        .fixedSize()
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(tint.opacity(0.10), in: Capsule())
    }

    // MARK: - Background

    private var exerciseBackground: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#FFF4D9"),
                        Color(hex: "#F8F0DE"),
                        Color(hex: "#DCEFFF")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                RoundedRectangle(cornerRadius: 64, style: .continuous)
                    .fill(LinearGradient(
                        colors: [Color(hex: "#B9E1FF"), Color(hex: "#8FB8FF")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: geo.size.width * 1.16, height: geo.size.height * 0.62)
                    .rotationEffect(.degrees(-8))
                    .offset(x: -geo.size.width * 0.04, y: geo.size.height * 0.48)
                RoundedRectangle(cornerRadius: 58, style: .continuous)
                    .fill(Color.white.opacity(0.18))
                    .frame(width: geo.size.width * 0.86, height: geo.size.height * 0.34)
                    .rotationEffect(.degrees(-10))
                    .offset(x: -geo.size.width * 0.24, y: geo.size.height * 0.68)
            }
        }
    }
}

#Preview("Exercises") {
    NavigationStack {
        ExerciseListScreen()
    }
    .environmentObject(AngleService())
}
