// ImageModel.swift
// Domain model — clean Swift struct, independent of any framework

import Foundation

// MARK: - ImageModel

struct ImageModel: Identifiable, Hashable, Equatable {
    let id: String
    let imageURL: String
    let thumbURL: String
    let authorName: String
    let width: Int
    let height: Int
    let color: String
    let description: String?

    var aspectRatio: CGFloat {
        guard height > 0 else { return 1 }
        return CGFloat(width) / CGFloat(height)
    }

    var colorHex: String { color }
}

// MARK: - Unsplash API Response DTOs

struct UnsplashPhoto: Decodable {
    let id: String
    let width: Int
    let height: Int
    let color: String?
    let description: String?
    let altDescription: String?
    let urls: UnsplashPhotoURLs
    let user: UnsplashUser

    enum CodingKeys: String, CodingKey {
        case id, width, height, color, description
        case altDescription = "alt_description"
        case urls, user
    }
}

struct UnsplashPhotoURLs: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct UnsplashUser: Decodable {
    let name: String
}

// MARK: - DTO → Domain Model Mapping

extension UnsplashPhoto {
    func toDomainModel() -> ImageModel {
        ImageModel(
            id: id,
            imageURL: urls.regular,
            thumbURL: urls.small,
            authorName: user.name,
            width: width,
            height: height,
            color: color ?? "#CCCCCC",
            description: description ?? altDescription
        )
    }
}

// MARK: - Realm → Domain Model Mapping

extension RealmImageObject {
    func toDomainModel() -> ImageModel {
        ImageModel(
            id: id,
            imageURL: imageURL,
            thumbURL: thumbURL,
            authorName: authorName,
            width: width,
            height: height,
            color: color,
            description: imageDescription.isEmpty ? nil : imageDescription
        )
    }
}

// PicsumPhoto.swift
// Decodable model matching picsum.photos /v2/list response

import Foundation

// MARK: - Response shape from picsum API
// GET https://picsum.photos/v2/list?page=1&limit=20
// [
//   {
//     "id": "0",
//     "author": "Alejandro Escamilla",
//     "width": 5616,
//     "height": 3744,
//     "url": "https://unsplash.com/...",
//     "download_url": "https://picsum.photos/id/0/5616/3744"
//   }
// ]

struct PicsumPhoto: Decodable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let url: String
    let downloadUrl: String   // snake_case → camelCase via .convertFromSnakeCase

    func toImageModel() -> ImageModel {
        // Use a fixed display size for consistent UI
        let displayWidth  = 1080
        let displayHeight = 1920

        return ImageModel(
            id:          "picsum-\(id)",
            imageURL:    "https://picsum.photos/id/\(id)/\(displayWidth)/\(displayHeight)",
            thumbURL:    "https://picsum.photos/id/\(id)/400/600",
            authorName:  author,
            width:       displayWidth,
            height:      displayHeight,
            color:       "#888888",   // picsum doesn't return color — use neutral fallback
            description: "Photo by \(author)"
        )
    }
}
