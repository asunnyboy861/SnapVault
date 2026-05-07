import Photos
import SwiftData
import SwiftUI

struct BrowseView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = BrowseViewModel()
    @State private var selectedCategory: SnapCategory?
    @State private var selectedSnapItem: SnapItem?

    var body: some View {
        NavigationStack {
            Group {
                if let category = selectedCategory {
                    categoryDetailView(category)
                } else {
                    categoryGridView
                }
            }
            .navigationTitle(selectedCategory == nil ? "Browse" : selectedCategory!.rawValue)
            .toolbar {
                if selectedCategory != nil {
                    ToolbarItem(placement: .topBarLeading) {
                        Button { selectedCategory = nil } label: {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
            }
            .onAppear { viewModel.loadCategories(modelContext: modelContext) }
        }
    }

    private var categoryGridView: some View {
        ScrollView {
            VStack(spacing: 16) {
                StorageStatCard(
                    totalMB: viewModel.totalStorageMB,
                    totalCount: viewModel.screenshots.count,
                    temporaryCount: viewModel.temporaryCount
                )

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(SnapCategory.allCases, id: \.self) { category in
                        CategoryBadge(
                            category: category,
                            count: viewModel.categoryCounts[category] ?? 0
                        )
                        .onTapGesture {
                            if (viewModel.categoryCounts[category] ?? 0) > 0 {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }

    private func categoryDetailView(_ category: SnapCategory) -> some View {
        let items = viewModel.filteredItems(for: category)
        return List(items) { item in
            ScreenshotRow(item: item)
                .onTapGesture { selectedSnapItem = item }
        }
        .sheet(item: $selectedSnapItem) { item in
            ScreenshotDetailView(item: item)
        }
    }
}

struct ScreenshotRow: View {
    let item: SnapItem
    @State private var thumbnail: UIImage?

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.originalFileName)
                    .font(.subheadline)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Label(item.category.rawValue, systemImage: item.category.icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if item.isTemporary {
                        Label("Temp", systemImage: "clock")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                    if item.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }
                }
                Text(item.creationDate, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Text("\(Double(item.fileSize) / 1024 / 1024, specifier: "%.1f") MB")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .task {
            let photoService = PhotoLibraryService()
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [item.assetIdentifier], options: nil)
            if let asset = fetchResult.firstObject {
                thumbnail = await photoService.loadThumbnail(for: asset)
            }
        }
    }
}
