// DIContainer.swift
// Dependency Injection Container — Factory pattern for all services and ViewModels

import Foundation

// MARK: - DI Container

final class DIContainer {

    static let shared = DIContainer()

    // MARK: - Services (lazy singletons)

    private(set) lazy var networkService: NetworkServiceProtocol = {
        NetworkService()
    }()

    private(set) lazy var realmManager: RealmManager = {
        RealmManager.shared
    }()

    private(set) lazy var authService: GoogleAuthServiceProtocol = {
        GoogleAuthService()
    }()

    private(set) lazy var imageRepository: ImageRepositoryProtocol = {
        ImageRepository(
            networkService: networkService,
            realmManager: realmManager
        )
    }()

    private init() {}

    // MARK: - ViewModel Factories

    func makeGalleryViewModel() -> GalleryViewModel {
        GalleryViewModel(repository: imageRepository)
    }

    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(authService: authService)
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(authService: authService)
    }
}
