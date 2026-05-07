import SafariServices
import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("isAutoScanEnabled") private var isAutoScanEnabled = true
    @AppStorage("isExpirationReminderEnabled") private var isExpirationReminderEnabled = true
    @State private var purchaseManager = PurchaseManager.shared
    @State private var showRescanConfirmation = false
    @State private var isRescanning = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                proSection
                scanSection
                notificationSection
                aboutSection
                resetSection
            }
            .navigationTitle("Settings")
        }
    }

    private var proSection: some View {
        Section {
            if purchaseManager.isProPurchased {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                    Text("Pro Unlocked")
                        .font(.headline)
                    Spacer()
                    Text("Active")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.blue)
                        Text("Upgrade to Pro")
                            .font(.headline)
                        Spacer()
                    }
                    Text("Unlock swipe cleaning, advanced search, Spotlight integration, and more.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button {
                        Task { _ = await purchaseManager.purchase() }
                    } label: {
                        if purchaseManager.isLoading {
                            ProgressView()
                        } else {
                            Text("Unlock — $4.99 (One-Time)")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    Button("Restore Purchases") {
                        Task { await purchaseManager.restorePurchases() }
                    }
                    .font(.caption)
                }
            }
        } header: {
            Text("Pro Features")
        }
    }

    private var scanSection: some View {
        Section {
            Toggle("Auto-Scan New Screenshots", isOn: $isAutoScanEnabled)
            Button {
                showRescanConfirmation = true
            } label: {
                HStack {
                    if isRescanning {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text("Rescan All Screenshots")
                }
            }
            .disabled(isRescanning)
        } header: {
            Text("Scanning")
        }
        .confirmationDialog("Rescan all screenshots?", isPresented: $showRescanConfirmation) {
            Button("Rescan", role: .destructive) {
                performRescan()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will re-classify all screenshots. Existing categories will be updated.")
        }
    }

    private var notificationSection: some View {
        Section {
            Toggle("Expiration Reminders", isOn: $isExpirationReminderEnabled)
        } header: {
            Text("Notifications")
        } footer: {
            Text("Get notified when temporary screenshots (OTP, QR codes) are about to expire.")
        }
    }

    private var aboutSection: some View {
        Section {
            NavigationLink {
                if let url = URL(string: "https://asunnyboy861.github.io/SnapVault/privacy") {
                    SafariView(url: url)
                }
            } label: {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            NavigationLink {
                if let url = URL(string: "https://asunnyboy861.github.io/SnapVault/support") {
                    SafariView(url: url)
                }
            } label: {
                Label("Support", systemImage: "questionmark.circle")
            }
            NavigationLink {
                ContactSupportView()
            } label: {
                Label("Contact Us", systemImage: "envelope")
            }
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("About")
        }
    }

    private var resetSection: some View {
        Section {
            Button(role: .destructive) {
                hasCompletedOnboarding = false
            } label: {
                Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
            }
        }
    }

    private func performRescan() {
        isRescanning = true
        Task {
            let descriptor = FetchDescriptor<SnapItem>()
            let items = (try? modelContext.fetch(descriptor)) ?? []
            for item in items {
                modelContext.delete(item)
            }
            try? modelContext.save()

            let photoService = PhotoLibraryService()
            photoService.checkAuthorization()
            guard photoService.isAuthorized else {
                await MainActor.run { isRescanning = false }
                return
            }

            let scanner = ScreenshotScanner()
            await scanner.scanAllScreenshots(photoService: photoService, modelContext: modelContext)

            await MainActor.run { isRescanning = false }
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
