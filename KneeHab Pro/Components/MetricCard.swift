import SwiftUI

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let tint: Color

    var body: some View {
        KHCard(cornerRadius: 22) {
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(tint)
                        .frame(width: 34, height: 34)
                        .background(tint.opacity(0.13), in: Circle())

                    Spacer(minLength: 0)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(value)
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(Color.khTextPrimary)
                            .minimumScaleFactor(0.7)
                        Text(unit)
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(Color.khTextSecondary)
                    }

                    Text(title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.khTextSecondary)
                        .lineLimit(2)
                }
            }
        }
    }
}

#Preview("Metric Card") {
    MetricCard(title: "Max flexion", value: "112", unit: "deg", icon: "target", tint: .khBlue)
        .padding()
        .background(Color.khBackground)
}
