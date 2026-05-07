import SwiftUI
import SwiftData

@main
struct SnapVaultApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var purchaseManager = PurchaseManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView {
                        hasCompletedOnboarding = true
                    }
                }
            }
            .environment(purchaseManager)
        }
        .modelContainer(for: [SnapItem.self, SearchEntry.self])
    }
}
