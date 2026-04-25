
// GalleryAppApp.swift
// App Entry Point — configures Google Sign-In and Realm

import SwiftUI
import GoogleSignIn
import RealmSwift
import Firebase

@main
struct GalleryApp: App {

    @StateObject private var coordinator = AppCoordinator()

    init() {
        FirebaseApp.configure()
        configureGoogleSignIn()
        configureRealm()
    }
    

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(coordinator)
                .onOpenURL { url in
                    // Handle Google Sign-In redirect
                    GIDSignIn.sharedInstance.handle(url)
                }
        }

    }

    // MARK: - Configuration

    private func configureGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("Missing Firebase Client ID")
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }

    private func configureRealm() {
        RealmManager.shared.configure()
    }
}
