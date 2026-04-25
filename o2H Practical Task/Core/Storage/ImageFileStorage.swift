// ImageFileStorage.swift
// Writes/reads image bytes to FileManager's Caches directory.
// Realm stores the file path. This stores the actual bytes.

import UIKit

//final class ImageFileStorage {
//
//    static let shared = ImageFileStorage()
//
//    private let cacheDir: URL
//
//    // Max cache size: 300 MB
//    static let maxCacheSizeBytes = 300 * 1024 * 1024
//
//    private init() {
//        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
//        cacheDir = caches.appendingPathComponent("GalleryImages", isDirectory: true)
//        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
//        print("🗂️ Image cache dir: \(cacheDir.path)")
//    }
//
//    // MARK: - Save
//
//    /// Saves image data to disk. Returns file path string, or nil on failure.
//    func save(data: Data, imageID: String, suffix: String) -> String? {
//        let fileURL = fileURL(imageID: imageID, suffix: suffix)
//        do {
//            try data.write(to: fileURL, options: .atomic)
//            return fileURL.path
//        } catch {
//            print("❌ ImageFileStorage save failed [\(imageID)_\(suffix)]: \(error)")
//            return nil
//        }
//    }
//
//    // MARK: - Load
//
//    /// Loads UIImage from a stored file path.
//    func load(path: String?) -> UIImage? {
//        guard let path, FileManager.default.fileExists(atPath: path) else { return nil }
//        return UIImage(contentsOfFile: path)
//    }
//
//    // MARK: - Delete
//
//    func delete(imageID: String) {
//        ["thumb", "full"].forEach { suffix in
//            try? FileManager.default.removeItem(at: fileURL(imageID: imageID, suffix: suffix))
//        }
//    }
//
//    func deleteAll() {
//        try? FileManager.default.removeItem(at: cacheDir)
//        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
//    }
//
//    // MARK: - Helpers
//
//    func fileExists(imageID: String, suffix: String) -> Bool {
//        FileManager.default.fileExists(atPath: fileURL(imageID: imageID, suffix: suffix).path)
//    }
//
//    private func fileURL(imageID: String, suffix: String) -> URL {
//        cacheDir.appendingPathComponent("\(imageID)_\(suffix).jpg")
//    }
//}
final class ImageFileStorage {
    static let shared = ImageFileStorage()
    private let cacheDir: URL
    static let maxCacheSizeBytes = 300 * 1024 * 1024

    private init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDir = caches.appendingPathComponent("GalleryImages", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    }

    // ✅ Returns only the filename (e.g., "123_thumb.jpg")
    func save(data: Data, imageID: String, suffix: String) -> String? {
        let fileName = "\(imageID)_\(suffix).jpg"
        let fileURL = cacheDir.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL, options: .atomic)
            return fileName
        } catch {
            print("❌ Save failed: \(error)")
            return nil
        }
    }
    // ✅ Reconstructs the path dynamically
    func getFullURL(for fileName: String?) -> URL? {
        guard let fileName = fileName else { return nil }
        return cacheDir.appendingPathComponent(fileName)
    }

    func load(fileName: String?) -> UIImage? {
        guard let url = getFullURL(for: fileName),
              FileManager.default.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
    
    func delete(imageID: String) {
           let thumbName = "\(imageID)_thumb.jpg"
           let fullName = "\(imageID)_full.jpg"
           
           [thumbName, fullName].forEach { fileName in
               let url = cacheDir.appendingPathComponent(fileName)
               try? FileManager.default.removeItem(at: url)
           }
       }
    // MARK: - Delete All
    func deleteAll() {
        do {
            // Poore folder ko delete karo
            try FileManager.default.removeItem(at: cacheDir)
            // Folder ko wapas create karo taaki future downloads fail na hon
            try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
            print("🗑️ Image cache cleared successfully")
        } catch {
            print("❌ Failed to delete all images: \(error)")
        }
    }
    // Update delete method to use filename logic...
}
