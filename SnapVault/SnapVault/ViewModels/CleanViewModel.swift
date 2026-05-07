import Photos
import SwiftData
import SwiftUI

@Observable
final class CleanViewModel {
    var candidates: [SnapItem] = []
    var currentIndex = 0
    var deletedCount = 0
    var keptCount = 0
    var freedMB: Double = 0
    var offset: CGFloat = 0
    var isComplete = false

    func loadCandidates(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<SnapItem>(
            predicate: #Predicate { $0.shouldSuggestDeletion },
            sortBy: [SortDescriptor(\.creationDate, order: .reverse)]
        )
        candidates = (try? modelContext.fetch(descriptor)) ?? []
        currentIndex = 0
        deletedCount = 0
        keptCount = 0
        freedMB = 0
        isComplete = false
    }

    var currentItem: SnapItem? {
        guard currentIndex < candidates.count else { return nil }
        return candidates[currentIndex]
    }

    var progress: Double {
        guard !candidates.isEmpty else { return 0 }
        return Double(currentIndex) / Double(candidates.count)
    }

    func performSwipe(direction: SwipeDirection, photoService: PhotoLibraryService, modelContext: ModelContext) {
        guard currentIndex < candidates.count else { return }
        let item = candidates[currentIndex]

        if direction == .left {
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [item.assetIdentifier], options: nil)
            if let asset = fetchResult.firstObject {
                Task { _ = await photoService.deleteAssets([asset]) }
            }
            deletedCount += 1
            freedMB += Double(item.fileSize) / 1024 / 1024
            modelContext.delete(item)
        } else {
            keptCount += 1
            item.isPinned = true
        }

        currentIndex += 1
        if currentIndex >= candidates.count {
            isComplete = true
        }
        try? modelContext.save()
    }

    func pinCurrent(modelContext: ModelContext) {
        guard currentIndex < candidates.count else { return }
        candidates[currentIndex].isPinned = true
        currentIndex += 1
        if currentIndex >= candidates.count {
            isComplete = true
        }
        try? modelContext.save()
    }
}

enum SwipeDirection {
    case left, right
}
