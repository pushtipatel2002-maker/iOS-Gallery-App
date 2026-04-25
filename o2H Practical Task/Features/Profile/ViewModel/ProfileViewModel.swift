// ProfileViewModel.swift
// Loads user from GIDSignIn → falls back to Realm.
// Uses async load so GIDSignIn session is fully restored before reading.

import Foundation
import GoogleSignIn
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {

    @Published private(set) var user: UserModel?

    private let authService: GoogleAuthServiceProtocol

    init(authService: GoogleAuthServiceProtocol) {
        self.authService = authService
        // Sync load first (works if already in memory)
        loadUserSync()
        // Then async load to catch restored sessions
        Task { await loadUserAsync() }
    }

    // MARK: - Sync (fast path — works when user is already in memory)

    private func loadUserSync() {
        // 1. In-memory from auth service (set during sign-in)
        if let u = authService.currentUser {
            user = u
            return
        }
        // 2. Realm fallback (persisted from last session)
        if let realmUser = RealmManager.shared.fetchAll(RealmUserObject.self).first {
            user = UserModel(
                id: realmUser.id,
                email: realmUser.email,
                displayName: realmUser.displayName,
                photoURL: realmUser.photoURL
            )
        }
    }

    // MARK: - Async (catches restored GIDSignIn sessions)
    // GIDSignIn.restorePreviousSignIn completes after init,
    // so we must also read currentUser after a short wait.

    private func loadUserAsync() async {
        // Already loaded — skip
        if user != nil { return }

        // Wait briefly for GIDSignIn session restore to complete
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s

        // Try GIDSignIn current user directly
        if let gUser = GIDSignIn.sharedInstance.currentUser,
           let profile = gUser.profile {
            user = UserModel(
                id: gUser.userID ?? "",
                email: profile.email,
                displayName: profile.name,
                photoURL: profile.imageURL(withDimension: 200)?.absoluteString ?? ""
            )
            // Also persist to Realm so next time sync load works
            persistToRealm(user!)
            return
        }

        // Final fallback — Realm
        if let realmUser = RealmManager.shared.fetchAll(RealmUserObject.self).first {
            user = UserModel(
                id: realmUser.id,
                email: realmUser.email,
                displayName: realmUser.displayName,
                photoURL: realmUser.photoURL
            )
        }
    }

    // MARK: - Persist

    private func persistToRealm(_ userModel: UserModel) {
        let obj = RealmUserObject(
            id: userModel.id,
            email: userModel.email,
            displayName: userModel.displayName,
            photoURL: userModel.photoURL
        )
        RealmManager.shared.write(obj)
    }
}
