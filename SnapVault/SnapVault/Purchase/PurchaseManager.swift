import StoreKit
import SwiftUI

@Observable
final class PurchaseManager {
    var isProPurchased = false
    var isLoading = false
    var product: Product?

    private let productId = "com.zzoutuo.SnapVault.pro"

    static let shared = PurchaseManager()

    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = listenForTransactions()
        Task { await loadProduct() }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productId])
            product = products.first
        } catch {
        }
    }

    func purchase() async -> Bool {
        guard let product = product else { return false }
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                isProPurchased = true
                await transaction.finish()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            return false
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchaseStatus()
        } catch {
        }
    }

    func updatePurchaseStatus() async {
        for await result in StoreKit.Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == productId {
                    isProPurchased = transaction.revocationDate == nil
                    return
                }
            }
        }
        isProPurchased = false
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in StoreKit.Transaction.updates {
                if case .verified(let transaction) = result {
                    if transaction.productID == self?.productId {
                        await MainActor.run {
                            self?.isProPurchased = transaction.revocationDate == nil
                        }
                    }
                    await transaction.finish()
                }
            }
        }
    }

    private func checkVerified(_ result: VerificationResult<StoreKit.Transaction>) throws -> StoreKit.Transaction {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let transaction):
            return transaction
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
