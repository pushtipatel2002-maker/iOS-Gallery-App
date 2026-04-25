// AppCoordinator.swift
// Coordinator pattern — manages app-level navigation state

import SwiftUI
import Combine
import GoogleSignIn

// MARK: - App State

enum AppState {
    case splash
    case login
    case main
}

// MARK: - AppCoordinator

@MainActor
final class AppCoordinator: ObservableObject {

    @Published var appState: AppState = .splash
    @Published var selectedTab: Tab = .gallery
    private let authService: GoogleAuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    enum Tab: Hashable {
        case gallery
        case profile
    }

    init(authService: GoogleAuthServiceProtocol = GoogleAuthService()) {
        self.authService = authService
        checkAuthState()
    }

    // MARK: - Auth Flow

    private func checkAuthState() {
        Task {
            //  Splash delay
            try? await Task.sleep(nanoseconds: 1_500_000_000)

            if let localUser = authService.checkLocalSession() {
                print("✅ Offline session found in Realm")
                appState = .main
                
                Task {
                    try? await authService.restoreSession()
                }
            } else {
                print("❌ No local session, going to login")
                appState = .login
            }
        }
    }
    
    private func restorePreviousSignIn() async {
        do {
            try await GIDSignIn.sharedInstance.restorePreviousSignIn()
            appState = .main
        } catch {
            appState = .login
        }
    }


    func navigateToMain() {
        appState = .main
    }

    func navigateToLogin() {
        appState = .login
    }

    func logout() {
        authService.signOut()
        navigateToLogin()
    }
}

// MARK: - RootView

struct RootView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        Group {
            switch coordinator.appState {
            case .splash:
                SplashView()
            case .login:
                LoginView()
            case .main:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.4), value: coordinator.appState)
    }
}
