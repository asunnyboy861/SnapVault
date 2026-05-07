import Photos
import SwiftData
import UIKit

@Observable
final class ScreenshotScanner {
    private let classificationService = ClassificationService()
    var isScanning = false
    var scanProgress: Double = 0
    var scannedCount = 0
    var totalCount = 0

    func scanAllScreenshots(
        photoService: PhotoLibraryService,
        modelContext: ModelContext
    ) async {
        guard !isScanning else { return }
        isScanning = true
        scanProgress = 0
        scannedCount = 0

        let assets = photoService.fetchAllScreenshots()
        totalCount = assets.count

        let existingIds = fetchExistingAssetIds(modelContext: modelContext)
        let newAssets = assets.filter { !existingIds.contains($0.localIdentifier) }

        totalCount = newAssets.count
        guard totalCount > 0 else {
            isScanning = false
            return
        }

        await withTaskGroup(of: Void.self) { group in
            for (index, asset) in newAssets.enumerated() {
                group.addTask { [weak self] in
                    await self?.processScreenshot(asset: asset, photoService: photoService, modelContext: modelContext)
                    await MainActor.run {
                        self?.scannedCount = index + 1
                        self?.scanProgress = Double(index + 1) / Double(newAssets.count)
                    }
                }
            }
        }

        isScanning = false
    }

    private func processScreenshot(
        asset: PHAsset,
        photoService: PhotoLibraryService,
        modelContext: ModelContext
    ) async {
        guard let image = await photoService.loadThumbnail(
            for: asset,
            size: CGSize(width: 299, height: 299)
        ), let cgImage = image.cgImage else { return }

        let result = await classificationService.classify(asset: cgImage)

        let fileSize = photoService.getFileSize(for: asset)
        let snapItem = SnapItem(
            assetIdentifier: asset.localIdentifier,
            fileName: asset.value(forKey: "filename") as? String ?? "Screenshot",
            creationDate: asset.creationDate ?? Date(),
            fileSize: fileSize,
            width: Int(asset.pixelWidth),
            height: Int(asset.pixelHeight)
        )

        snapItem.category = result.category
        snapItem.isTemporary = result.isTemporary
        snapItem.isProcessed = true

        if result.isTemporary, let hours = result.category.defaultExpirationHours {
            snapItem.expirationDate = Calendar.current.date(byAdding: .hour, value: hours, to: Date())
        }

        if result.confidence < 0.6 {
            snapItem.category = .unsorted
        }

        await MainActor.run {
            modelContext.insert(snapItem)
            try? modelContext.save()
        }
    }

    private func fetchExistingAssetIds(modelContext: ModelContext) -> Set<String> {
        let descriptor = FetchDescriptor<SnapItem>(sortBy: [])
        let items = (try? modelContext.fetch(descriptor)) ?? []
        return Set(items.map(\.assetIdentifier))
    }
}
