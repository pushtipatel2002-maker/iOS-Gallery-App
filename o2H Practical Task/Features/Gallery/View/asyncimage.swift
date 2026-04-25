//// AsyncImageLoader.swift
//// Loads from disk cache first, falls back to URL stream.
//// Published state drives SwiftUI — no blank intermediate flashes.
//
//import SwiftUI
//import Combine
//
//@MainActor
//final class AsyncImageLoader: ObservableObject {
//
//    enum State {
//        case idle
//        case loading
//        case loaded(UIImage)
//        case failed
//    }
//
//    @Published private(set) var state: State = .idle
//
//    private var task: Task<Void, Never>?
//
//    // MARK: - Load
//
//    func load(imageID: String, url: URL) {
//        // Already loaded — don't reload
//        if case .loaded = state { return }
//
//        task?.cancel()
//        state = .loading
//
//        task = Task {
//            // 1. Try disk cache first (instant — no network)
//            if let diskImage = ImageFileStorage.shared.loadThumb(imageID: imageID)
//                ?? ImageFileStorage.shared.loadFull(imageID: imageID) {
//                guard !Task.isCancelled else { return }
//                self.state = .loaded(diskImage)
//                return
//            }
//
//            // 2. Stream from URL directly — don't wait for background download
//            do {
//                let (data, _) = try await URLSession.shared.data(from: url)
//                guard !Task.isCancelled else { return }
//                if let image = UIImage(data: data) {
//                    // Save to disk so next open is instant
//                    ImageFileStorage.shared.saveThumb(imageID: imageID, data: data)
//                    self.state = .loaded(image)
//                } else {
//                    self.state = .failed
//                }
//            } catch {
//                guard !Task.isCancelled else { return }
//                self.state = .failed
//            }
//        }
//    }
//
//    func cancel() {
//        task?.cancel()
//        task = nil
//        state = .idle
//    }
//}
