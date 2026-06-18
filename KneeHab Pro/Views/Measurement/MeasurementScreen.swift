import SwiftUI

struct MeasurementScreen: View {
    var body: some View {
        ZStack {
            measurementBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    topBar
                    comingSoonCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 34)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "angle")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.black)
                .frame(width: 38, height: 38)
                .background(Color.white.opacity(0.86), in: Circle())

            Text("Measurement")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.black)

            Spacer()
        }
        .padding(.leading, 8)
        .padding(.trailing, 16)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 14, x: 0, y: 8)
    }

    private var comingSoonCard: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.72))
                    .frame(width: 112, height: 112)

                Image(systemName: "ruler.fill")
                    .font(.system(size: 44, weight: .black))
                    .foregroundStyle(Color.khBlue)
            }

            VStack(spacing: 8) {
                Text("ROM Measurement")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)

                Text("Feature coming soon")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khBlue)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 520)
        .padding(26)
        .background(
            LinearGradient(
                colors: [Color(hex: "#AAEE00"), Color(hex: "#DFFF72"), Color(hex: "#F2FFD0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 34, style: .continuous)
        )
        .shadow(color: Color.khGreen.opacity(0.22), radius: 24, x: 0, y: 16)
    }

    private var measurementBackground: some View {
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
                    .fill(Color.khBlue.opacity(0.16))
                    .frame(width: geo.size.width * 1.16, height: geo.size.height * 0.50)
                    .rotationEffect(.degrees(-8))
                    .offset(x: -geo.size.width * 0.04, y: geo.size.height * 0.55)
            }
        }
    }
}

#Preview("Measurement") {
    MeasurementScreen()
}
