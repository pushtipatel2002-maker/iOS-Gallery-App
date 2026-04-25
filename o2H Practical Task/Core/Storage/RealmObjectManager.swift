// RealmObjects.swift
// Realm stores metadata + file paths only. NO image Data blobs.

import Foundation
import RealmSwift

// MARK: - RealmImageObject

final class RealmImageObject: Object {

    @Persisted(primaryKey: true) var id: String          = ""
    @Persisted var imageURL: String                      = ""
    @Persisted var thumbURL: String                      = ""
    @Persisted var authorName: String                    = ""
    @Persisted var width: Int                            = 0
    @Persisted var height: Int                           = 0
    @Persisted var color: String                         = "#CCCCCC"
    @Persisted var imageDescription: String              = ""
    @Persisted var pageNumber: Int                       = 1
    @Persisted var savedAt: Date                         = Date()

    // ✅ File paths on disk — NOT raw Data
    @Persisted var thumbFilePath: String?                = nil
    @Persisted var fullFilePath: String?                 = nil
    
    @Persisted var thumbFileName: String? = nil
    @Persisted var fullFileName: String?  = nil

    // ✅ For LRU eviction
    @Persisted var lastAccessedAt: Date                  = Date()
    @Persisted var fileSizeBytes: Int                    = 0   // thumb + full combined

    var isCached: Bool { thumbFilePath != nil }

    convenience init(from model: ImageModel, page: Int = 1) {
        self.init()
        self.id               = model.id
        self.imageURL         = model.imageURL
        self.thumbURL         = model.thumbURL
        self.authorName       = model.authorName
        self.width            = model.width
        self.height           = model.height
        self.color            = model.color
        self.imageDescription = model.description ?? ""
        self.pageNumber       = page
        self.savedAt          = Date()
        self.lastAccessedAt   = Date()
    }
}

// MARK: - RealmUserObject

final class RealmUserObject: Object {

    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var email: String                = ""
    @Persisted var displayName: String          = ""
    @Persisted var photoURL: String             = ""
    @Persisted var lastLoginAt: Date            = Date()

    convenience init(id: String, email: String, displayName: String, photoURL: String) {
        self.init()
        self.id          = id
        self.email       = email
        self.displayName = displayName
        self.photoURL    = photoURL
        self.lastLoginAt = Date()
    }
}
