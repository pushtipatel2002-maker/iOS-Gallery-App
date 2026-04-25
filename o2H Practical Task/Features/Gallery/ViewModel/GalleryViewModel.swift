// GalleryViewModel.swift
// Waits for network to settle before deciding online vs offline path.

import Foundation
import Combine
enum ViewState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
    case offline
}

@MainActor
final class GalleryViewModel: ObservableObject {

    @Published private(set) var images: [ImageModel]  = []
    @Published private(set) var viewState: ViewState  = .idle
    @Published private(set) var isLoadingMore: Bool   = false
    @Published private(set) var hasMorePages: Bool    = true
    @Published var selectedImage: ImageModel?         = nil

    private let repository: ImageRepositoryProtocol
    private var currentPage: Int = 0
    private var isFetching: Bool = false

    init(repository: ImageRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public

    func loadInitial() async {
        guard images.isEmpty else { return }
        viewState = .loading

        // ✅ Wait for NWPathMonitor to fire its real first value (max 2s)
        // This eliminates the race condition where isConnected is "true" at launch
        // even when device is actually offline
        let isOnline = await NetworkMonitor.shared.waitForSettled()
        print(" Settled network status: \(isOnline ? "Online" : "Offline")")

        if !isOnline && repository.hasCachedImages() {
            // Offline + cache exists → load all pages from Realm immediately
            loadAllCachedPages()
            viewState = .offline
            return
        }
        // Online (or no cache) → normal network fetch
        await fetchNextPage()
    }

    func refresh() async {
        currentPage  = 0
        images       = []
        hasMorePages = true
        await fetchNextPage()
    }

    func loadMoreIfNeeded(currentItem item: ImageModel) async {
        guard !isFetching, hasMorePages,
              let idx = images.firstIndex(of: item),
              idx >= images.count - 5 else { return }
        await fetchNextPage()
    }

    // MARK: - Load all cached pages (offline relaunch)

    private func loadAllCachedPages() {
        var page = 1
        var all: [ImageModel] = []
        while true {
            let pageImages = repository.fetchCachedImages(page: page)
            if pageImages.isEmpty { break }
            all.append(contentsOf: pageImages)
            page += 1
        }
        currentPage  = page - 1
        hasMorePages = false
        images       = all
        print("📦 Loaded \(all.count) cached images from \(page - 1) page(s) — offline mode")
    }

    // MARK: - Network fetch with Realm fallback

    private func fetchNextPage() async {
        guard !isFetching else { return }
        isFetching = true

        let nextPage = currentPage + 1
        if images.isEmpty { viewState = .loading }
        else { isLoadingMore = true }

        do {
            let fetched = try await repository.fetchImages(page: nextPage)
            if fetched.isEmpty {
                hasMorePages = false
            } else {
                currentPage = nextPage
                append(fetched)
                
                for image in fetched {
                    Task(priority: .background) {
                        await ImageDownloadService.shared.downloadAndCache(
                            imageID: image.id,
                            thumbURL: image.thumbURL,
                            fullURL: image.imageURL
                        )
                    }
                }
            }
            viewState = NetworkMonitor.shared.isConnected ? .loaded : .offline

        } catch {
            let cached = repository.fetchCachedImages(page: nextPage)
            if !cached.isEmpty {
                currentPage = nextPage
                append(cached)
                viewState = .offline
            } else if images.isEmpty {
                viewState = .error(error.localizedDescription)
            } else {
                hasMorePages = false
                viewState = .loaded
            }
        }

        isLoadingMore = false
        isFetching = false
    }

    private func append(_ new: [ImageModel]) {
        let existing = Set(images.map(\.id))
        images.append(contentsOf: new.filter { !existing.contains($0.id) })
    }
}

