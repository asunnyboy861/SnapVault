import Photos
import SwiftData
import SwiftUI

struct SwipeCleanView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = CleanViewModel()
    @State private var purchaseManager = PurchaseManager.shared
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            Group {
                if !purchaseManager.isProPurchased {
                    paywallGate
                } else if viewModel.candidates.isEmpty && !viewModel.isComplete {
                    emptyState
                } else if viewModel.isComplete {
                    completionState
                } else {
                    cardStack
                }
            }
            .navigationTitle("Clean Up")
        }
        .onAppear {
            if purchaseManager.isProPurchased {
                viewModel.loadCandidates(modelContext: modelContext)
            }
        }
    }

    private var paywallGate: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "lock.fill")
                .font(.system(size: 50))
                .foregroundStyle(.blue)
            Text("Pro Feature")
                .font(.title2.bold())
            Text("Swipe to Clean is a Pro feature.\nUpgrade once, use forever.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                Task { _ = await purchaseManager.purchase() }
            } label: {
                if purchaseManager.isLoading {
                    ProgressView()
                        .controlSize(.regular)
                } else {
                    Text("Unlock Pro — $4.99")
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            Button("Restore Purchases") {
                Task { await purchaseManager.restorePurchases() }
            }
            .font(.caption)
            Spacer()
        }
        .padding()
    }

    private var cardStack: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(viewModel.deletedCount) deleted")
                    .font(.caption)
                    .foregroundStyle(.red)
                Spacer()
                Text("\(viewModel.freedMB, specifier: "%.0f") MB freed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(viewModel.keptCount) kept")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            ProgressView(value: viewModel.progress)
                .padding(.horizontal)

            Spacer()

            if viewModel.currentIndex < viewModel.candidates.count {
                let item = viewModel.candidates[viewModel.currentIndex]
                ScreenshotCard(item: item, offset: viewModel.offset)
                    .gesture(swipeGesture)
                    .offset(x: viewModel.offset)
                    .rotationEffect(.degrees(Double(viewModel.offset) / 20))
            }

            Spacer()

            HStack(spacing: 40) {
                Button { performSwipe(.left) } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.red)
                }
                Button { viewModel.pinCurrent(modelContext: modelContext) } label: {
                    Image(systemName: "pin.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.blue)
                }
                Button { performSwipe(.right) } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.green)
                }
            }
            .padding(.bottom, 40)
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in viewModel.offset = value.translation.width }
            .onEnded { value in
                let threshold: CGFloat = 100
                if value.translation.width < -threshold {
                    performSwipe(.left)
                } else if value.translation.width > threshold {
                    performSwipe(.right)
                } else {
                    withAnimation(.spring()) { viewModel.offset = 0 }
                }
            }
    }

    private func performSwipe(_ direction: SwipeDirection) {
        let photoService = PhotoLibraryService()
        withAnimation(.easeOut(duration: 0.3)) {
            viewModel.offset = direction == .left ? -500 : 500
        }
        viewModel.performSwipe(direction: direction, photoService: photoService, modelContext: modelContext)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.offset = 0
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            Text("All Clean!")
                .font(.title.bold())
            Text("No screenshots need cleaning right now.")
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var completionState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            Text("Session Complete")
                .font(.title.bold())
            Text("Deleted \(viewModel.deletedCount) screenshots, freed \(viewModel.freedMB, specifier: "%.0f") MB")
                .foregroundStyle(.secondary)
            Text("Kept \(viewModel.keptCount) screenshots")
                .foregroundStyle(.secondary)
            Button("Done") {
                viewModel.loadCandidates(modelContext: modelContext)
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
    }
}

struct ScreenshotCard: View {
    let item: SnapItem
    var offset: CGFloat = 0
    @State private var thumbnail: UIImage?

    var body: some View {
        VStack(spacing: 12) {
            Group {
                if let image = thumbnail {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Color.gray.opacity(0.2)
                        .aspectRatio(9/16, contentMode: .fit)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 10)
            .frame(maxWidth: 280)

            VStack(spacing: 4) {
                Text(item.category.rawValue)
                    .font(.caption.bold())
                if item.isTemporary {
                    Label("Temporary", systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
                Text(item.creationDate, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background {
            let color = offset < -50 ? Color.red.opacity(0.3) :
                        offset > 50 ? Color.green.opacity(0.3) : Color.clear
            RoundedRectangle(cornerRadius: 20).fill(color)
        }
        .task {
            let photoService = PhotoLibraryService()
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [item.assetIdentifier], options: nil)
            if let asset = fetchResult.firstObject {
                thumbnail = await photoService.loadThumbnail(for: asset, size: CGSize(width: 400, height: 400))
            }
        }
    }
}
