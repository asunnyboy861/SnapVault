import Foundation

enum SnapCategory: String, Codable, CaseIterable {
    case otp = "OTP & Codes"
    case qrCode = "QR Codes"
    case receipt = "Receipts"
    case document = "Documents"
    case conversation = "Conversations"
    case shopping = "Shopping"
    case travel = "Travel"
    case food = "Food & Recipes"
    case code = "Code Snippets"
    case social = "Social Media"
    case finance = "Finance"
    case work = "Work"
    case meme = "Memes & Fun"
    case reference = "Reference"
    case unsorted = "Unsorted"

    var icon: String {
        switch self {
        case .otp: return "lock.shield"
        case .qrCode: return "qrcode"
        case .receipt: return "receipt"
        case .document: return "doc.text"
        case .conversation: return "bubble.left.and.bubble.right"
        case .shopping: return "bag"
        case .travel: return "airplane"
        case .food: return "fork.knife"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .social: return "person.2"
        case .finance: return "dollarsign.circle"
        case .work: return "briefcase"
        case .meme: return "face.smiling"
        case .reference: return "bookmark"
        case .unsorted: return "questionmark.folder"
        }
    }

    var isTemporaryByDefault: Bool {
        switch self {
        case .otp, .qrCode: return true
        default: return false
        }
    }

    var defaultExpirationHours: Int? {
        switch self {
        case .otp: return 24
        case .qrCode: return 72
        default: return nil
        }
    }

    var color: String {
        switch self {
        case .otp, .qrCode: return "orange"
        case .receipt, .finance: return "blue"
        case .conversation, .social: return "purple"
        case .code: return "cyan"
        case .shopping: return "pink"
        case .travel: return "teal"
        case .food: return "green"
        case .document, .work: return "indigo"
        case .meme: return "yellow"
        case .reference: return "gray"
        case .unsorted: return "secondary"
        }
    }
}
