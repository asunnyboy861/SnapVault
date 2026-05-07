import SwiftUI

struct CategoryBadge: View {
    let category: SnapCategory
    let count: Int

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: 56, height: 56)
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundStyle(colorForCategory)
            }
            Text(category.rawValue)
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if count > 0 {
                Text("\(count)")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(colorForCategory.opacity(0.8)))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var colorForCategory: Color {
        switch category {
        case .otp, .qrCode: return .orange
        case .receipt, .finance: return .blue
        case .conversation, .social: return .purple
        case .code: return .cyan
        case .shopping: return .pink
        case .travel: return .teal
        case .food: return .green
        case .document, .work: return .indigo
        case .meme: return .yellow
        case .reference: return .gray
        case .unsorted: return .secondary
        }
    }
}
