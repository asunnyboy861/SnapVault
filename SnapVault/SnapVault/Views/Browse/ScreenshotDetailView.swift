import Photos
import SwiftUI
import SwiftData

struct ScreenshotDetailView: View {
    let item: SnapItem
    @Environment(\.dismiss) private var dismiss
    @State private var fullImage: UIImage?
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Group {
                        if let image = fullImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            ProgressView()
                                .frame(height: 300)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 8)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label(item.category.rawValue, systemImage: item.category.icon)
                                .font(.subheadline.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.1), in: Capsule())
                            if item.isTemporary {
                                Label("Temporary", systemImage: "clock")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.orange.opacity(0.1), in: Capsule())
                            }
                            Spacer()
                            Button {
                                item.isPinned.toggle()
                            } label: {
                                Image(systemName: item.isPinned ? "pin.fill" : "pin")
                                    .foregroundStyle(item.isPinned ? .blue : .gray)
                            }
                        }

                        DetailRow(label: "File", value: item.originalFileName)
                        DetailRow(label: "Date", value: item.creationDate.formatted(date: .abbreviated, time: .shortened))
                        DetailRow(label: "Size", value: String(format: "%.2f MB", Double(item.fileSize) / 1024 / 1024))
                        DetailRow(label: "Resolution", value: "\(item.width) x \(item.height)")

                        if let ocrText = item.ocrText, !ocrText.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Detected Text")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(ocrText)
                                    .font(.footnote)
                                    .textSelection(.enabled)
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                            }
                        }

                        if !item.detectedLinks.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Detected Links")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                ForEach(item.detectedLinks, id: \.self) { link in
                                    Link(link, destination: URL(string: link) ?? URL(string: "https://example.com")!)
                                        .font(.footnote)
                                }
                            }
                        }

                        if !item.detectedAmounts.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Detected Amounts")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                ForEach(item.detectedAmounts, id: \.self) { amount in
                                    Text(amount)
                                        .font(.footnote.bold())
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Screenshot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .confirmationDialog("Delete Screenshot?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteScreenshot()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete the screenshot from your photo library.")
            }
        }
        .task { await loadFullImage() }
    }

    private func loadFullImage() async {
        let photoService = PhotoLibraryService()
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [item.assetIdentifier], options: nil)
        if let asset = fetchResult.firstObject {
            fullImage = await photoService.loadFullSizeImage(for: asset)
        }
    }

    private func deleteScreenshot() {
        let photoService = PhotoLibraryService()
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [item.assetIdentifier], options: nil)
        if let asset = fetchResult.firstObject {
            Task {
                _ = await photoService.deleteAssets([asset])
                dismiss()
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.subheadline)
            Spacer()
        }
    }
}
