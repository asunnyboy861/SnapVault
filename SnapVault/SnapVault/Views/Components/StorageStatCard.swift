import SwiftUI

struct StorageStatCard: View {
    let totalMB: Double
    let totalCount: Int
    let temporaryCount: Int

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Storage Used")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(totalMB, specifier: "%.1f") MB")
                        .font(.title2.bold())
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Screenshots")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(totalCount)")
                        .font(.title2.bold())
                }
            }

            if temporaryCount > 0 {
                HStack {
                    Image(systemName: "clock.badge")
                        .foregroundStyle(.orange)
                    Text("\(temporaryCount) temporary screenshot\(temporaryCount > 1 ? "s" : "") expiring")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Spacer()
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}
