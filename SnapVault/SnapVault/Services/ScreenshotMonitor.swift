import Photos
import SwiftData
import UIKit

final class ScreenshotMonitor: NSObject, PHPhotoLibraryChangeObserver {
    private let modelContainer: ModelContainer
    private let classificationService = ClassificationService()

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        super.init()
        PHPhotoLibrary.shared().register(self)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(
            format: "mediaSubtype == %d",
            PHAssetMediaSubtype.photoScreenshot.rawValue
        )
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        guard let details = changeInstance.changeDetails(for: fetchResult) else { return }

        for asset in details.insertedObjects {
            Task { await processNewScreenshot(asset) }
        }
    }

    private func processNewScreenshot(_ asset: PHAsset) async {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat

        guard let image = await withCheckedContinuation({ (continuation: CheckedContinuation<UIImage?, Never>) in
            let targetSize = CGSize(width: 299, height: 299)
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }), let cgImage = image.cgImage else { return }

        let result = await classificationService.classify(asset: cgImage)

        let context = ModelContext(modelContainer)
        let snapItem = SnapItem(
            assetIdentifier: asset.localIdentifier,
            fileName: asset.value(forKey: "filename") as? String ?? "Screenshot",
            creationDate: asset.creationDate ?? Date(),
            fileSize: 0,
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

        context.insert(snapItem)
        try? context.save()

        if result.isTemporary {
            await NotificationService.shared.scheduleExpirationNotification(for: snapItem)
        }
    }
}
