import Foundation
import SwiftData

@Model
final class SearchEntry {
    var id: UUID
    var keyword: String
    var source: SearchSource
    var snapItem: SnapItem?

    init(keyword: String, source: SearchSource) {
        self.id = UUID()
        self.keyword = keyword.lowercased()
        self.source = source
    }
}

enum SearchSource: String, Codable {
    case ocr = "ocr"
    case userTag = "user_tag"
    case link = "link"
    case amount = "amount"
}
