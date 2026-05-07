import SwiftData
import SwiftUI

@Observable
final class BrowseViewModel {
    var selectedCategory: SnapCategory?
    var searchText = ""
    var screenshots: [SnapItem] = []
    var categoryCounts: [SnapCategory: Int] = [:]
    var totalStorageMB: Double = 0
    var temporaryCount = 0

    func loadCategories(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<SnapItem>(sortBy: [SortDescriptor(\.creationDate, order: .reverse)])
        let items = (try? modelContext.fetch(descriptor)) ?? []
        screenshots = items
        categoryCounts = Dictionary(grouping: items, by: \.category).mapValues(\.count)
        totalStorageMB = Double(items.reduce(Int64(0)) { $0 + $1.fileSize }) / 1024 / 1024
        temporaryCount = items.filter(\.isTemporary).count
    }

    func filteredItems(for category: SnapCategory?) -> [SnapItem] {
        guard let category = category else { return screenshots }
        return screenshots.filter { $0.category == category }
    }
}
