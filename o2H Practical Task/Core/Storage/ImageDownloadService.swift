// ImageDownloadService.swift
// Downloads image bytes → saves to FileManager → updates Realm with file path + size.
// Also runs LRU eviction after each save to stay under 300MB.

import UIKit

protocol ImageDownloadServiceProtocol {
    func downloadAndCache(imageID: String, thumbURL: String, fullURL: String) async
}

final class ImageDownloadService: ImageDownloadServiceProtocol {

    static let shared = ImageDownloadService()

    private let session: URLSession
    private let fileStorage = ImageFileStorage.shared
    private let realmManager = RealmManager.shared

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Download & Cache

    func downloadAndCache(imageID: String, thumbURL: String, fullURL: String) async {
        // ✅ Skip if already cached on disk
        let alreadyCached = await MainActor.run {
            guard let obj = realmManager.fetch(RealmImageObject.self, primaryKey: imageID) else {
                return false
            }
            return obj.isCached
        }
        guard !alreadyCached else { return }

        // Download both concurrently
        async let thumbFetch = downloadData(from: thumbURL)
        async let fullFetch  = downloadData(from: fullURL)
        let (thumbData, fullData) = await (thumbFetch, fullFetch)

        guard thumbData != nil || fullData != nil else {
            print("❌ Both downloads failed for: \(imageID)")
            return
        }

        // Save bytes to FileManager
        let thumbPath = thumbData.flatMap { fileStorage.save(data: $0, imageID: imageID, suffix: "thumb") }
        let fullPath  = fullData.flatMap  { fileStorage.save(data: $0, imageID: imageID, suffix: "full") }

        // Calculate combined file size
        let totalSize = (thumbData?.count ?? 0) + (fullData?.count ?? 0)

        // ✅ Update Realm with file paths + size (on MainActor)
        await MainActor.run {
            guard let obj = realmManager.fetch(RealmImageObject.self, primaryKey: imageID) else { return }
            realmManager.updateImagePaths(
                object: obj,
                thumbFileName: thumbPath,
                fullFileName: fullPath,
                sizeBytes: totalSize
            )
            print("✅ Cached to disk: \(imageID) (\(totalSize / 1024)KB)")
        }

        // ✅ Run LRU eviction if over limit
        await MainActor.run {
            realmManager.evictIfNeeded()
        }
    }

    // MARK: - Private

    private func downloadData(from urlString: String) async -> Data? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse,
                  (200...299).contains(http.statusCode) else { return nil }
            return data
        } catch {
            print("⚠️ Download failed (\(urlString)): \(error.localizedDescription)")
            return nil
        }
    }
}
