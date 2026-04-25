// RealmManager.swift
// Main-thread Realm manager with LRU eviction support.

import Foundation
import RealmSwift

final class RealmManager {

    static let shared = RealmManager()
    private var realm: Realm?

    private init() {}

    // MARK: - Configure

    func configure() {
        let config = Realm.Configuration(
            schemaVersion: 4,
            migrationBlock: { _, _ in },
            deleteRealmIfMigrationNeeded: true
        )
        Realm.Configuration.defaultConfiguration = config
        do {
            realm = try Realm()
            print("✅ Realm at: \(Realm.Configuration.defaultConfiguration.fileURL?.path ?? "?")")
        } catch {
            print("❌ Realm init failed: \(error)")
        }
    }

    // MARK: - DB accessor

    private func db() throws -> Realm {
        if let r = realm { return r }
        let r = try Realm()
        realm = r
        return r
    }

    // MARK: - Write

    func write<T: Object>(_ object: T) {
        do { let r = try db(); try r.write { r.add(object, update: .modified) } }
        catch { print("❌ write: \(error)") }
    }

    func writeAll<T: Object>(_ objects: [T]) {
        do { let r = try db(); try r.write { r.add(objects, update: .modified) } }
        catch { print("❌ writeAll: \(error)") }
    }

    func delete<T: Object>(_ object: T) {
        do { let r = try db(); try r.write { r.delete(object) } }
        catch { print("❌ delete: \(error)") }
    }

    func deleteAll<T: Object>(ofType type: T.Type) {
        do { let r = try db(); try r.write { r.delete(r.objects(type)) } }
        catch { print("❌ deleteAll: \(error)") }
    }

    // MARK: - Read

    func fetchAll<T: Object>(_ type: T.Type) -> [T] {
        (try? Array(db().objects(type))) ?? []
    }

    func fetch<T: Object>(_ type: T.Type, primaryKey: String) -> T? {
        try? db().object(ofType: type, forPrimaryKey: primaryKey)
    }

    func fetchSorted<T: Object>(_ type: T.Type, by keyPath: String, ascending: Bool = true) -> [T] {
        (try? Array(db().objects(type).sorted(byKeyPath: keyPath, ascending: ascending))) ?? []
    }

    func hasCachedImages() -> Bool {
        (try? db().objects(RealmImageObject.self).isEmpty) == false
    }

    // MARK: - Update image file paths (called after download)

    func updateImagePaths(object: RealmImageObject, thumbFileName: String?, fullFileName: String?, sizeBytes: Int) {
        do {
            let r = try db()
            try r.write {
                object.thumbFileName  = thumbFileName
                object.fullFileName   = fullFileName
                object.fileSizeBytes  = sizeBytes
                object.lastAccessedAt = Date()
            }
        } catch { print("❌ updateImagePaths: \(error)") }
    }

    // MARK: - Update last accessed (called when image is viewed)

    func touchAccessTime(imageID: String) {
        guard let obj = fetch(RealmImageObject.self, primaryKey: imageID) else { return }
        do {
            let r = try db()
            try r.write { obj.lastAccessedAt = Date() }
        } catch { print("❌ touchAccessTime: \(error)") }
    }

    // MARK: - ✅ LRU Eviction
    // When total cache exceeds maxSizeBytes, delete least-recently-accessed images first.

    // ... baki code same rahega ...

        func evictIfNeeded(maxSizeBytes: Int = ImageFileStorage.maxCacheSizeBytes) {
            let all = fetchSorted(RealmImageObject.self, by: "lastAccessedAt", ascending: true)
            var totalBytes = all.reduce(0) { $0 + $1.fileSizeBytes }

            guard totalBytes > maxSizeBytes else { return }

            for obj in all {
                guard totalBytes > maxSizeBytes else { break }
                guard obj.isCached else { continue }

                // Delete files from disk
                ImageFileStorage.shared.delete(imageID: obj.id)

                let freed = obj.fileSizeBytes
                do {
                    let r = try db()
                    try r.write {
                        // ✅ Updated property names here
                        obj.thumbFileName  = nil
                        obj.fullFileName   = nil
                        obj.fileSizeBytes  = 0
                    }
                } catch { continue }

                totalBytes -= freed
            }
        }

    var isEmpty: Bool { (try? db().isEmpty) ?? true }
}
