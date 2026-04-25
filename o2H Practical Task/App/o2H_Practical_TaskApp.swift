import SwiftUI
import GoogleSignIn
import RealmSwift

@main
struct GalleryApp: App {

    @StateObject private var coordinator = AppCoordinator()

    init() {
        configureGoogleSignIn()
        configureRealm()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(coordinator)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }

    private func configureGoogleSignIn() {
        guard let clientID = Bundle.main.object(
            forInfoDictionaryKey: "GIDClientID"
        ) as? String else {
            fatalError("Missing GIDClientID in Info.plist")
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
    }

    private func configureRealm() {
        RealmManager.shared.configure()
    }
}
