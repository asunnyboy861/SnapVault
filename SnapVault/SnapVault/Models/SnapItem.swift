import Foundation
import SwiftData

@Model
final class SnapItem {
    @Attribute(.unique) var id: UUID
    var assetIdentifier: String
    var originalFileName: String
    var creationDate: Date
    var fileSize: Int64
    var width: Int
    var height: Int
    var category: SnapCategory
    var isTemporary: Bool
    var isPinned: Bool
    var isProcessed: Bool
    var expirationDate: Date?
    var ocrText: String?
    var tags: [String]
    var detectedLinks: [String]
    var detectedAmounts: [String]

    var daysSinceCreation: Int {
        Calendar.current.dateComponents([.day], from: creationDate, to: Date()).day ?? 0
    }

    var shouldSuggestDeletion: Bool {
        if isPinned { return false }
        if isTemporary, let exp = expirationDate, exp < Date() { return true }
        if daysSinceCreation > 180 && !isPinned { return true }
        return false
    }

    init(assetIdentifier: String, fileName: String, creationDate: Date,
         fileSize: Int64, width: Int, height: Int) {
        self.id = UUID()
        self.assetIdentifier = assetIdentifier
        self.originalFileName = fileName
        self.creationDate = creationDate
        self.fileSize = fileSize
        self.width = width
        self.height = height
        self.category = .unsorted
        self.isTemporary = false
        self.isPinned = false
        self.isProcessed = false
        self.expirationDate = nil
        self.tags = []
        self.detectedLinks = []
        self.detectedAmounts = []
    }
}
