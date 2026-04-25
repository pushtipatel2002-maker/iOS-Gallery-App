// ImageRepository.swift
// Fetch from picsum API → cache to Realm + disk → serve offline from cache

import Foundation

protocol ImageRepositoryProtocol {
    func fetchImages(page: Int) async throws -> [ImageModel]
    func fetchCachedImages(page: Int) -> [ImageModel]
    func hasCachedImages() -> Bool
    func clearCache()
}

final class ImageRepository: ImageRepositoryProtocol {

    private let networkService: NetworkServiceProtocol
    private let realmManager: RealmManager

    init(networkService: NetworkServiceProtocol, realmManager: RealmManager) {
        self.networkService = networkService
        self.realmManager   = realmManager
    }

    // MARK: - Fetch

    func fetchImages(page: Int) async throws -> [ImageModel] {
        do {
            // Always try the real API first (picsum — no key needed)
            let models = try await fetchFromNetwork(page: page)
            guard !models.isEmpty else { return [] }
            // Persist metadata to Realm
            saveMetadata(models, page: page)

            // Download image bytes to disk in background
            Task.detached(priority: .background) {
                await withTaskGroup(of: Void.self) { group in
                    for model in models {
                        group.addTask {
                            await ImageDownloadService.shared.downloadAndCache(
                                imageID: model.id,
                                thumbURL: model.thumbURL,
                                fullURL: model.imageURL
                            )
                        }
                    }
                }
            }

            return models

        } catch {
            // Network failed — serve from Realm cache if available
            print("🌐 Network failed: \(error.localizedDescription) — falling back to Realm cache")
            let cached = fetchCachedImages(page: page)
            if !cached.isEmpty { return cached }
            throw error
        }
    }

    // MARK: - Cache

    func fetchCachedImages(page: Int) -> [ImageModel] {
        realmManager
            .fetchSorted(RealmImageObject.self, by: "savedAt", ascending: true)
            .filter { $0.pageNumber == page }
            .map    { $0.toDomainModel() }
    }

    func hasCachedImages() -> Bool {
        !realmManager.fetchAll(RealmImageObject.self).isEmpty
    }

    func clearCache() {
        realmManager.deleteAll(ofType: RealmImageObject.self)
        ImageFileStorage.shared.deleteAll()
    }

    // MARK: - Private

    private func fetchFromNetwork(page: Int) async throws -> [ImageModel] {
        // PicsumPhoto must be a Decodable struct matching picsum's JSON shape
        let photos: [PicsumPhoto] = try await networkService.fetch(.photos(page: page))
        return photos.map { $0.toImageModel() }
    }

    private func saveMetadata(_ models: [ImageModel], page: Int) {
        let objects = models.map { RealmImageObject(from: $0, page: page) }
        realmManager.writeAll(objects)
    }
}
