import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage = 0
    @State private var isRequestingPermission = false

    var body: some View {
        TabView(selection: $currentPage) {
            welcomePage.tag(0)
            featurePage.tag(1)
            privacyPage.tag(2)
            permissionPage.tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "photo.stack")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            Text("SnapVault")
                .font(.largeTitle.bold())
            Text("Your Screenshots, Sorted")
                .font(.title3)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Get Started") { withAnimation { currentPage = 1 } }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            Spacer().frame(height: 40)
        }
        .padding()
    }

    private var featurePage: some View {
        VStack(spacing: 24) {
            Spacer()
            FeatureRow(icon: "brain", title: "AI Categories", desc: "15 smart categories, zero effort")
            FeatureRow(icon: "text.magnifyingglass", title: "Search by Text", desc: "Find screenshots by the words inside")
            FeatureRow(icon: "hand.draw", title: "Swipe to Clean", desc: "Tinder-style cleanup, reclaim space")
            FeatureRow(icon: "clock.badge", title: "Auto-Expiry", desc: "OTP and QR codes expire automatically")
            Spacer()
            Button("Next") { withAnimation { currentPage = 2 } }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            Spacer().frame(height: 40)
        }
        .padding()
    }

    private var privacyPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            Text("100% Private")
                .font(.title.bold())
            Text("All processing happens on your device. No cloud uploads. No data collection. Your screenshots stay yours.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            Spacer()
            Button("Next") { withAnimation { currentPage = 3 } }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            Spacer().frame(height: 40)
        }
        .padding()
    }

    private var permissionPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            Text("Photo Access Required")
                .font(.title.bold())
            Text("SnapVault needs access to your photo library to scan and organize screenshots.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            Spacer()
            Button {
                isRequestingPermission = true
                Task {
                    let photoService = PhotoLibraryService()
                    let granted = await photoService.requestAuthorization()
                    _ = await NotificationService.shared.requestAuthorization()
                    isRequestingPermission = false
                    if granted { onComplete() }
                }
            } label: {
                if isRequestingPermission {
                    ProgressView()
                        .controlSize(.regular)
                } else {
                    Text("Allow Access")
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            Spacer().frame(height: 40)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let desc: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(desc).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
