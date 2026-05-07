import SwiftData
import SwiftUI

@Observable
final class SearchViewModel {
    var searchText = ""
    var searchResults: [SnapItem] = []
    var recentSearches: [String] = []
    var isSearching = false
    var selectedFilter: SearchFilter?

    func search(modelContext: ModelContext) {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        isSearching = true

        let keyword = searchText.lowercased()
        let descriptor = FetchDescriptor<SnapItem>(sortBy: [SortDescriptor(\.creationDate, order: .reverse)])
        let allItems = (try? modelContext.fetch(descriptor)) ?? []

        searchResults = allItems.filter { item in
            if let filter = selectedFilter {
                switch filter {
                case .otp: guard item.category == .otp || item.category == .qrCode else { return false }
                case .amount: guard !item.detectedAmounts.isEmpty else { return false }
                case .shopping: guard item.category == .shopping else { return false }
                case .document: guard item.category == .document else { return false }
                }
            }
            if let ocrText = item.ocrText, ocrText.lowercased().contains(keyword) { return true }
            if item.originalFileName.lowercased().contains(keyword) { return true }
            if item.tags.contains(where: { $0.lowercased().contains(keyword) }) { return true }
            if item.detectedLinks.contains(where: { $0.lowercased().contains(keyword) }) { return true }
            if item.detectedAmounts.contains(where: { $0.lowercased().contains(keyword) }) { return true }
            return false
        }

        if !searchText.isEmpty && !recentSearches.contains(searchText) {
            recentSearches.insert(searchText, at: 0)
            if recentSearches.count > 10 {
                recentSearches.removeLast()
            }
        }

        isSearching = false
    }
}

enum SearchFilter: String, CaseIterable {
    case otp = "OTP & Codes"
    case amount = "Amounts"
    case shopping = "Shopping"
    case document = "Documents"
}
