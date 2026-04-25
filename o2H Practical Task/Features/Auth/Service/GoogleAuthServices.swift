// GoogleAuthService.swift
// Google Sign-In service abstraction

import Foundation
import GoogleSignIn
import UIKit

// MARK: - Protocol

protocol GoogleAuthServiceProtocol {
    var currentUser: UserModel? { get }
    func signIn(presenting viewController: UIViewController) async throws -> UserModel
    func signOut()
    func restoreSession() async throws -> UserModel
    func checkLocalSession() -> UserModel?

}

// MARK: - Implementation

final class GoogleAuthService: GoogleAuthServiceProtocol {

    private(set) var currentUser: UserModel?

    // MARK: - Sign In

    func signIn(presenting viewController: UIViewController) async throws -> UserModel {
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        let user = try mapUser(result.user)
        self.currentUser = user

        // Persist user to Realm
        persistUser(user)
        return user
    }
    // MARK: -check Session

    func checkLocalSession() -> UserModel? {
            if let realmUser = RealmManager.shared.fetchAll(RealmUserObject.self).first {
                return UserModel(
                    id: realmUser.id,
                    email: realmUser.email,
                    displayName: realmUser.displayName,
                    photoURL: realmUser.photoURL
                )
            }
            return nil
        }
    
    // MARK: - Restore Session

    func restoreSession() async throws -> UserModel {
        do {
            try await GIDSignIn.sharedInstance.restorePreviousSignIn()
            guard let gUser = GIDSignIn.sharedInstance.currentUser else {
                throw AuthError.noCurrentUser
            }
            let user = try mapUser(gUser)
            self.currentUser = user
            
            persistUser(user)
            return user
        } catch {
            if let local = checkLocalSession() {
                self.currentUser = local
                return local
            }
            throw error
        }
    }

    // MARK: - Sign Out

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        currentUser = nil
        // Clear persisted user
        RealmManager.shared.deleteAll(ofType: RealmUserObject.self)
    }

    // MARK: - Helpers

    private func mapUser(_ gUser: GIDGoogleUser) throws -> UserModel {
        guard let profile = gUser.profile else {
            throw AuthError.missingProfile
        }
        return UserModel(
            id: gUser.userID ?? UUID().uuidString,
            email: profile.email,
            displayName: profile.name,
            photoURL: profile.imageURL(withDimension: 200)?.absoluteString ?? ""
        )
    }

    private func persistUser(_ user: UserModel) {
        let realmUser = RealmUserObject(
            id: user.id,
            email: user.email,
            displayName: user.displayName,
            photoURL: user.photoURL
        )
        RealmManager.shared.write(realmUser)
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case noCurrentUser
    case missingProfile
    case signInCancelled

    var errorDescription: String? {
        switch self {
        case .noCurrentUser:   return "No signed-in user found."
        case .missingProfile:  return "Could not load user profile."
        case .signInCancelled: return "Sign-in was cancelled."
        }
    }
}
