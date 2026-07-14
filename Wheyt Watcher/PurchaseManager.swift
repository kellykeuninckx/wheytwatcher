import StoreKit
import Combine

/// Eenmalige (non-consumable) aankoop, geen abonnement — zoals besproken in de marketing-richting.
@MainActor
final class PurchaseManager: ObservableObject {

    static let premiumProductID = "com.wheytwatcher.premium"

    @Published private(set) var isPremiumUnlocked: Bool = false
    @Published private(set) var premiumProduct: Product?
    @Published var purchaseErrorMessage: String?
    @Published private(set) var isLoadingProduct = true

    private var updateListenerTask: Task<Void, Never>?

    init() {
        updateListenerTask = listenForTransactionUpdates()

        Task {
            await loadProducts()
            await refreshEntitlementStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    func loadProducts() async {
        isLoadingProduct = true
        defer { isLoadingProduct = false }

        do {
            let products = try await Product.products(for: [Self.premiumProductID])
            premiumProduct = products.first
        } catch {
            purchaseErrorMessage = "Kon productinformatie niet laden. Probeer het later opnieuw."
        }
    }

    func purchasePremium() async {
        guard let product = premiumProduct else { return }
        purchaseErrorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                isPremiumUnlocked = true
                await transaction.finish()

            case .userCancelled, .pending:
                break

            @unknown default:
                break
            }
        } catch {
            purchaseErrorMessage = "De aankoop is niet gelukt. Probeer het opnieuw."
        }
    }

    func restorePurchases() async {
        purchaseErrorMessage = nil

        do {
            try await AppStore.sync()
            await refreshEntitlementStatus()

            if !isPremiumUnlocked {
                purchaseErrorMessage = "Geen eerdere aankoop gevonden voor dit Apple ID."
            }
        } catch {
            purchaseErrorMessage = "Terugzetten is niet gelukt. Probeer het opnieuw."
        }
    }

    func refreshEntitlementStatus() async {
        var unlocked = false

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result), transaction.productID == Self.premiumProductID {
                unlocked = true
            }
        }

        isPremiumUnlocked = unlocked
    }

    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                if let transaction = try? self.checkVerified(result) {
                    await transaction.finish()
                    await self.refreshEntitlementStatus()
                }
            }
        }
    }

    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private enum StoreError: Error {
        case failedVerification
    }

}
