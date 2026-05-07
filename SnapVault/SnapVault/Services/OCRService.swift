import Vision
import UIKit

actor OCRService {
    func performOCR(on image: CGImage) async -> OCRResult {
        await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, _ in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: OCRResult(text: "", hasOTP: false, hasAmount: false, links: []))
                    return
                }
                let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")
                let hasOTP = Self.detectOTP(in: text)
                let hasAmount = Self.detectAmount(in: text)
                let links = Self.extractLinks(from: text)
                continuation.resume(returning: OCRResult(text: text, hasOTP: hasOTP, hasAmount: hasAmount, links: links))
            }
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]
            request.usesLanguageCorrection = true
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            try? handler.perform([request])
        }
    }

    func detectQRCode(in image: CGImage) async -> Bool {
        await withCheckedContinuation { continuation in
            let request = VNDetectBarcodesRequest { request, _ in
                let hasBarcode = !(request.results?.isEmpty ?? true)
                continuation.resume(returning: hasBarcode)
            }
            request.symbologies = [.qr, .aztec, .pdf417, .dataMatrix]
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            try? handler.perform([request])
        }
    }

    private static func detectOTP(in text: String) -> Bool {
        let otpPatterns = [
            "\\b\\d{4,8}\\b",
            "(?i)verification\\s*code",
            "(?i)one.time\\s*password",
            "(?i)OTP",
            "(?i)authentication\\s*code",
            "(?i)confirm.*code",
            "(?i)your.*code.*is"
        ]
        return otpPatterns.contains { text.range(of: $0, options: .regularExpression) != nil }
    }

    private static func detectAmount(in text: String) -> Bool {
        let amountPattern = "[$€£¥]\\d+[.,]\\d{2}"
        return text.range(of: amountPattern, options: .regularExpression) != nil
    }

    private static func extractLinks(from text: String) -> [String] {
        let urlPattern = "https?://[\\w\\-._~:/?#\\[\\]@!$&'()*+,;=%]+"
        guard let regex = try? NSRegularExpression(pattern: urlPattern) else { return [] }
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        return matches.compactMap { Range($0.range, in: text).map { String(text[$0]) } }
    }
}

struct OCRResult {
    let text: String
    let hasOTP: Bool
    let hasAmount: Bool
    let links: [String]
}
