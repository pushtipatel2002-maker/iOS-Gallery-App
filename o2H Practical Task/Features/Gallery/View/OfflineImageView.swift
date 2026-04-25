// OfflineImageView.swift

import SwiftUI
import Combine

enum ImageSize { case thumb, full }

struct OfflineImageView: View {

    let imageID:  String
    let thumbURL: String
    let fullURL:  String
    let size:     ImageSize

    @StateObject private var loader: OfflineImageLoader

    init(imageID: String, thumbURL: String, fullURL: String, size: ImageSize = .thumb) {
        self.imageID  = imageID
        self.thumbURL = thumbURL
        self.fullURL  = fullURL
        self.size     = size
        _loader = StateObject(wrappedValue: OfflineImageLoader(
            imageID: imageID, thumbURL: thumbURL, fullURL: fullURL, size: size
        ))
    }

    var body: some View {
        ZStack {
            // ✅ Base layer — always gray, never a flash of white
            Color(.systemGray6)

            switch loader.state {
            case .idle, .loading:
                // ✅ Shimmer shown immediately from first frame — no blank gap
                ShimmerView()

            case .loaded(let img):
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    // ✅ Smooth fade-in only when image arrives
                    .transition(.opacity.animation(.easeIn(duration: 0.2)))

            case .failed:
                Image(systemName: "icloud.slash")
                    .font(.system(size: 24))
                    .foregroundStyle(.secondary)
            }
        }
        .task { await loader.load() }  // ✅ .task fires before first render, .onAppear fires after
    }
}

// MARK: - Load State

enum ImageLoadState {
    case idle
    case loading
    case loaded(UIImage)
    case failed
}

// MARK: - Loader

@MainActor
final class OfflineImageLoader: ObservableObject {

    // ✅ Single source of truth — no separate isLoading + image? that can desync
    @Published private(set) var state: ImageLoadState = .idle

    private let imageID:  String
    private let thumbURL: String
    private let fullURL:  String
    private let size:     ImageSize

    private let fileStorage  = ImageFileStorage.shared
    private let realmManager = RealmManager.shared

    init(imageID: String, thumbURL: String, fullURL: String, size: ImageSize) {
        self.imageID  = imageID
        self.thumbURL = thumbURL
        self.fullURL  = fullURL
        self.size     = size
    }

    func load() async {
        // ✅ Already loaded or loading — don't restart
        if case .loaded = state { return }
        if case .loading = state { return }

        // ✅ Set loading immediately — view sees this before any async work
        state = .loading

        // 1. Try disk cache first (fast path — works offline too)
        if let img = readFromDisk() {
            withAnimation { state = .loaded(img) }
            realmManager.touchAccessTime(imageID: imageID)
            return
        }

        // 2. Need to download — check network
        let isOnline = await NetworkMonitor.shared.waitForSettled()
        guard isOnline else {
            state = .failed
            return
        }

        // 3. Download and cache
        await ImageDownloadService.shared.downloadAndCache(
            imageID: imageID,
            thumbURL: thumbURL,
            fullURL: fullURL
        )

        // 4. Read what was just saved
        if let img = readFromDisk() {
            withAnimation { state = .loaded(img) }
        } else {
            state = .failed
        }
    }

    // MARK: - Read from disk via Realm path

    private func readFromDisk() -> UIImage? {
        guard let obj = realmManager.fetch(RealmImageObject.self, primaryKey: imageID) else {
            return nil
        }
        
        // Use the new load method that handles relative paths
        switch size {
        case .thumb:
            if let img = fileStorage.load(fileName: obj.thumbFileName) { return img }
        case .full:
            if let img = fileStorage.load(fileName: obj.fullFileName) { return img }
        }
        return nil
    }
}
