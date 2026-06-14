import SwiftUI

extension Color {
    static let khBackground = Color(hex: "#F5F8FA")
    static let khSurface = Color.white
    static let khSurfaceSecondary = Color(hex: "#EAF0F4")
    static let khTextPrimary = Color(hex: "#17212B")
    static let khTextSecondary = Color(hex: "#667482")
    static let khBlue = Color(hex: "#1E78FF")
    static let khBlueDark = Color(hex: "#1357C8")
    static let khMint = Color(hex: "#2ED3A6")
    static let khGreen = Color(hex: "#67C95B")
    static let khOrange = Color(hex: "#FF9F2E")
    static let khRed = Color(hex: "#EF4D5A")
    static let khPurple = Color(hex: "#7A67F8")
    static let khBorder = Color.black.opacity(0.08)

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

struct ScreenHeader: View {
    let title: String
    let subtitle: String
    var icon: String? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 31, weight: .black, design: .rounded))
                    .foregroundStyle(Color.khTextPrimary)
                    .minimumScaleFactor(0.82)

                Text(subtitle)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.khTextSecondary)
            }

            Spacer(minLength: 0)

            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Color.khBlue, in: Circle())
                    .shadow(color: .khBlue.opacity(0.22), radius: 10, x: 0, y: 5)
            }
        }
    }
}

struct KHCard<Content: View>: View {
    var cornerRadius: CGFloat = 24
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .background(Color.khSurface, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.khBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
}

struct StatusPill: View {
    let text: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .black))
            Text(text)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .lineLimit(1)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(tint.opacity(0.13), in: Capsule())
    }
}
