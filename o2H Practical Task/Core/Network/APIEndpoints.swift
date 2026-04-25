// APIEndpoint.swift

import Foundation

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
}

// MARK: - API Config

enum APIConfig {
    static let baseURL = "https://picsum.photos"
}

// MARK: - API Endpoint

struct APIEndpoint {

    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]?
    let headers: [String: String]

    var url: URL? {
        var components = URLComponents(string: APIConfig.baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }

    func validatedURL() throws -> URL {
        guard let url else { throw NetworkError.invalidURL }
        return url
    }
}

// MARK: - Endpoint Definitions

extension APIEndpoint {

    /// Fetch a page of photos from picsum.
    static func photos(page: Int, perPage: Int = 20) -> APIEndpoint {
        APIEndpoint(
            path: "/v2/list",
            method: .get,
            queryItems: [
                URLQueryItem(name: "page",  value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(perPage)")
            ],
            headers: [:]
        )
    }
}
