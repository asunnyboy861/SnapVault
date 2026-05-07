import Photos
import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var photoService = PhotoLibraryService()
    @State private var scanner = ScreenshotScanner()
    @State private var monitor: ScreenshotMonitor?
    @State private var showPermissionAlert = false

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView(selection: $selectedTab) {
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "square.grid.2x2")
                }
                .tag(0)

            SwipeCleanView()
                .tabItem {
                    Label("Clean", systemImage: "hand.draw")
                }
                .tag(1)

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(3)
        }
        .onAppear {
            setupMonitor()
            Task { await performInitialScan() }
        }
        .alert("Photo Access Required", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("SnapVault needs photo access to scan and organize your screenshots. Please enable it in Settings.")
        }
    }

    private func setupMonitor() {
        let container = modelContext.container
        monitor = ScreenshotMonitor(modelContainer: container)
    }

    private func performInitialScan() async {
        photoService.checkAuthorization()
        guard photoService.isAuthorized else {
            if photoService.authorizationStatus == .denied || photoService.authorizationStatus == .restricted {
                await MainActor.run { showPermissionAlert = true }
            }
            return
        }
        await scanner.scanAllScreenshots(photoService: photoService, modelContext: modelContext)
    }
}
