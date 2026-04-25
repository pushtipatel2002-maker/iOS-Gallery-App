
// AuthViewModel.swift
// ViewModel for login screen

import Foundation
import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {

    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    private let authService: GoogleAuthServiceProtocol

    init(authService: GoogleAuthServiceProtocol) {
        self.authService = authService
    }

    func signInWithGoogle(presenting viewController: UIViewController) async -> UserModel? {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await authService.signIn(presenting: viewController)
            isLoading = false
            return user
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
