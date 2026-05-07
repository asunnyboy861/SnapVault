import CoreGraphics
import Foundation

actor ClassificationService {
    private let ocrService = OCRService()

    func classify(asset: CGImage) async -> ClassificationResult {
        async let ocrResult = ocrService.performOCR(on: asset)
        async let qrResult = ocrService.detectQRCode(in: asset)
        let (ocr, qr) = await (ocrResult, qrResult)
        return resolveClassification(ocr: ocr, qr: qr)
    }

    private func resolveClassification(ocr: OCRResult, qr: Bool) -> ClassificationResult {
        if qr {
            return ClassificationResult(category: .qrCode, confidence: 0.95, isTemporary: true)
        }
        if ocr.hasOTP {
            return ClassificationResult(category: .otp, confidence: 0.95, isTemporary: true)
        }
        if ocr.hasAmount {
            let text = ocr.text.lowercased()
            if text.contains("receipt") || text.contains("invoice") || text.contains("order") {
                return ClassificationResult(category: .receipt, confidence: 0.85, isTemporary: false)
            }
            if text.contains("bank") || text.contains("transfer") || text.contains("balance") {
                return ClassificationResult(category: .finance, confidence: 0.85, isTemporary: false)
            }
        }
        if !ocr.links.isEmpty {
            let text = ocr.text.lowercased()
            if text.contains("shop") || text.contains("cart") || text.contains("buy") || text.contains("amazon") {
                return ClassificationResult(category: .shopping, confidence: 0.8, isTemporary: false)
            }
        }
        let text = ocr.text.lowercased()
        if text.contains("error") || text.contains("stack trace") || text.contains("exception") || text.contains("func ") {
            return ClassificationResult(category: .code, confidence: 0.75, isTemporary: false)
        }
        if text.contains("flight") || text.contains("boarding") || text.contains("reservation") || text.contains("hotel") {
            return ClassificationResult(category: .travel, confidence: 0.8, isTemporary: false)
        }
        if text.contains("recipe") || text.contains("ingredients") || text.contains("calories") {
            return ClassificationResult(category: .food, confidence: 0.8, isTemporary: false)
        }
        if !ocr.links.isEmpty {
            return ClassificationResult(category: .shopping, confidence: 0.6, isTemporary: false)
        }
        if !ocr.text.isEmpty {
            return ClassificationResult(category: .unsorted, confidence: 0.3, isTemporary: false)
        }
        return ClassificationResult(category: .unsorted, confidence: 0, isTemporary: false)
    }
}

struct ClassificationResult {
    let category: SnapCategory
    let confidence: Float
    let isTemporary: Bool
}
