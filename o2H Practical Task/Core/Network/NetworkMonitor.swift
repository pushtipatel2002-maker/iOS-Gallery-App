// NetworkMonitor.swift

import Network
import Foundation
import Combine

final class NetworkMonitor {

    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue   = DispatchQueue(label: "com.app.NetworkMonitor")

    // ✅ Published so ViewModels can react to changes
    @Published private(set) var isConnected: Bool = true
    private var isSettled = false

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let connected = path.status == .satisfied
            DispatchQueue.main.async {
                self.isConnected = connected
                self.isSettled   = true
            }
        }
        monitor.start(queue: queue)
    }

    // ✅ Waits up to 2 seconds for NWPathMonitor to fire its first real value.
    // NWPathMonitor is async — at app launch isConnected may be stale.
    func waitForSettled(timeout: TimeInterval = 2.0) async -> Bool {
        if isSettled { return isConnected }

        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            try? await Task.sleep(nanoseconds: 50_000_000) // 50ms poll
            if isSettled { return isConnected }
        }

        // Timeout — assume online (fail open, let network request confirm)
        print("⚠️ NetworkMonitor settle timeout — assuming online")
        return true
    }
}
