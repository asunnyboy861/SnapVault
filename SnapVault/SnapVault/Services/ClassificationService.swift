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
            return ClassificationResult(
                category: .qrCode,
                confidence: 0.95,
                isTemporary: true,
                ocrText: ocr.text,
                detectedLinks: ocr.links,
                detectedAmounts: []
            )
        }
        if ocr.hasOTP {
            return ClassificationResult(
                category: .otp,
                confidence: 0.95,
                isTemporary: true,
                ocrText: ocr.text,
                detectedLinks: ocr.links,
                detectedAmounts: []
            )
        }
        if ocr.hasAmount {
            let text = ocr.text.lowercased()
            if text.contains("receipt") || text.contains("invoice") || text.contains("order") {
                return ClassificationResult(
                    category: .receipt,
                    confidence: 0.85,
                    isTemporary: false,
                    ocrText: ocr.text,
                    detectedLinks: ocr.links,
                    detectedAmounts: extractAmounts(from: ocr.text)
                )
            }
            if text.contains("bank") || text.contains("transfer") || text.contains("balance") {
                return ClassificationResult(
                    category: .finance,
                    confidence: 0.85,
                    isTemporary: false,
                    ocrText: ocr.text,
                    detectedLinks: ocr.links,
                    detectedAmounts: extractAmounts(from: ocr.text)
                )
            }
        }
        if !ocr.links.isEmpty {
            let text = ocr.text.lowercased()
            if text.contains("shop") || text.contains("cart") || text.contains("buy") || text.contains("amazon") {
                return ClassificationResult(
                    category: .shopping,
                    confidence: 0.8,
                    isTemporary: false,
                    ocrText: ocr.text,
                    detectedLinks: ocr.links,
                    detectedAmounts: extractAmounts(from: ocr.text)
                )
            }
        }
        let text = ocr.text.lowercased()
        if text.contains("error") || text.contains("stack trace") || text.contains("exception") || text.contains("func ") {
            return ClassificationResult(
                category: .code,
                confidence: 0.75,
                isTemporary: false,
                ocrText: ocr.text,
                detectedLinks: ocr.links,
                detectedAmounts: []
            )
        }
        if text.contains("flight") || text.contains("boarding") || text.contains("reservation") || text.contains("hotel") {
            return ClassificationResult(
                category: .travel,
                confidence: 0.8,
                isTemporary: false,
                ocrText: ocr.text,
                detectedLinks: ocr.links,
                detectedAmounts: extractAmounts(from: ocr.text)
            )
        }
        if text.contains("recipe") || text.contains("ingredients") || text.contains("calories") {
            return ClassificationResult(
                category: .food,
                confidence: 0.8,
                isTemporary: false,
                ocrText: ocr.text,
                detectedLinks: ocr.links,
                detectedAmounts: []
            )
        }
        if text.contains("conversation") || text.contains("chat") || text.contains("message") || text.contains("sent") || text.contains("received") {
            return ClassificationResult(
                category: .conversation,
                confidence: 0.7,
                isTemporary: false,
                ocrText: ocr.text,
                detectedLinks: ocr.links,
                detectedAmounts: []
            )
        }
        if text.contains("instagram") || text.contains("twitter") || text.contains("facebook") || text.contains("tiktok") || text.contains("social") {
            return ClassificationResult(
                category: .social,
                confidence: 0.75,
                isTemporary: false,
                ocrText: ocr.text,
                detectedLinks: ocr.links,
                detectedAmounts: []
            )
        }
        if text.contains("meme") || text.contains("funny") || text.contains("lol") || text.contains("haha") {
            return ClassificationResult(
                category: .meme,
                confidence: 0.7,
                isTemporary: false,
                ocrText: ocr.text,
                detectedLinks: ocr.links,
                detectedAmounts: []
            )
        }
        if text.contains("meeting") || text.contains("project") || text.contains("deadline") || text.contains("task") {
            return ClassificationResult(
                category: .work,
                confidence: 0.75,
                isTemporary: false,
                ocrText: ocr.text,
                detectedLinks: ocr.links,
                detectedAmounts: []
            )
        }
        if text.contains("document") || text.contains("pdf") || text.contains("report") || text.contains("contract") {
            return ClassificationResult(
                category: .document,
                confidence: 0.75,
                isTemporary: false,
                ocrText: ocr.text,
                detectedLinks: ocr.links,
                detectedAmounts: []
            )
        }
        if !ocr.links.isEmpty {
            return ClassificationResult(
                category: .shopping,
                confidence: 0.6,
                isTemporary: false,
                ocrText: ocr.text,
                detectedLinks: ocr.links,
                detectedAmounts: extractAmounts(from: ocr.text)
            )
        }
        if !ocr.text.isEmpty {
            return ClassificationResult(
                category: .unsorted,
                confidence: 0.3,
                isTemporary: false,
                ocrText: ocr.text,
                detectedLinks: ocr.links,
                detectedAmounts: extractAmounts(from: ocr.text)
            )
        }
        return ClassificationResult(
            category: .unsorted,
            confidence: 0,
            isTemporary: false,
            ocrText: "",
            detectedLinks: [],
            detectedAmounts: []
        )
    }

    private func extractAmounts(from text: String) -> [String] {
        let pattern = "[$€£¥]\\d+[.,]\\d{2}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        return matches.compactMap { Range($0.range, in: text).map { String(text[$0]) } }
    }
}

struct ClassificationResult {
    let category: SnapCategory
    let confidence: Float
    let isTemporary: Bool
    let ocrText: String
    let detectedLinks: [String]
    let detectedAmounts: [String]
}
