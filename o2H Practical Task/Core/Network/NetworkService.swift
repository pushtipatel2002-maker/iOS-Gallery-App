// NetworkService.swift
// Generic network layer using async/await

import Foundation

// MARK: - Protocol

protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

// MARK: - Errors

enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingFailed(String)  // carries message, not the raw Error (not Equatable)
    case noInternet
    case cancelled
    case timeout

    var errorDescription: String? {
        switch self {
        case .invalidURL:           return "The request URL is invalid."
        case .invalidResponse:      return "The server returned an unreadable response."
        case .statusCode(let code): return "Server error (HTTP \(code))."
        case .decodingFailed(let msg): return "Failed to decode response: \(msg)"
        case .noInternet:           return "No internet connection. Please check your network."
        case .cancelled:            return "The request was cancelled."
        case .timeout:              return "The request timed out. Please try again."
        }
    }

    /// Whether it's worth retrying this error automatically.
    var isRetryable: Bool {
        switch self {
        case .statusCode(let code): return code >= 500
        case .timeout:              return true
        default:                    return false
        }
    }
}

// MARK: - Retry Policy

struct RetryPolicy {
    /// Maximum number of retry attempts (not counting the initial attempt).
    let maxAttempts: Int
    /// Seconds to wait before the first retry. Doubles on each subsequent attempt (exponential backoff).
    let initialDelay: TimeInterval

    static let `default` = RetryPolicy(maxAttempts: 2, initialDelay: 0.5)
    static let none      = RetryPolicy(maxAttempts: 0, initialDelay: 0)
}

// MARK: - Implementation

final class NetworkService: NetworkServiceProtocol {

    // MARK: Shared Instance

    static let shared = NetworkService()

    // MARK: Private Properties

    private let session: URLSession
    private let decoder: JSONDecoder
    private let retryPolicy: RetryPolicy

    // MARK: Init

    init(
        session: URLSession = NetworkService.makeSession(),
        retryPolicy: RetryPolicy = .default
    ) {
        self.session     = session
        self.retryPolicy = retryPolicy

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy  = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - URLSession Factory

    /// Dedicated session isolated from `.shared` — custom timeout,
    /// no cookie/credential sharing with the rest of the app.
    private static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = 15   // seconds until we give up on a single request
        config.timeoutIntervalForResource = 60   // seconds until we give up on the full resource

        config.httpAdditionalHeaders = [
            "Accept": "application/json"
        ]
        return URLSession(configuration: config)
    }

    // MARK: - Fetch

    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let url = try endpoint.validatedURL()
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        // Per-endpoint headers override session-level headers (e.g. auth overrides for tests)
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        return try await performWithRetry(request: request)
    }

    // MARK: - Retry Loop

    private func performWithRetry<T: Decodable>(request: URLRequest) async throws -> T {
        var lastError: NetworkError = .invalidResponse
        var delay = retryPolicy.initialDelay

        for attempt in 0...retryPolicy.maxAttempts {
            // Respect cooperative cancellation before each attempt
            try Task.checkCancellation()

            if attempt > 0 {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                delay *= 2  // exponential backoff
            }

            do {
                return try await performRequest(request)
            } catch let error as NetworkError {
                lastError = error

                // Propagate non-retryable errors immediately
                guard error.isRetryable else { throw error }

                // On last attempt, stop retrying
                if attempt == retryPolicy.maxAttempts { throw error }

            } catch is CancellationError {
                throw NetworkError.cancelled
            }
        }

        throw lastError
    }

    // MARK: - Single Request

    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            throw mapURLError(urlError)
        } catch is CancellationError {
            throw NetworkError.cancelled
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.statusCode(httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }

    // MARK: - URLError Mapping

    private func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet,
             .networkConnectionLost,
             .dataNotAllowed:
            return .noInternet

        case .timedOut:
            return .timeout

        case .cancelled:
            return .cancelled

        default:
            return .statusCode(error.errorCode)
        }
    }
}

// MARK: - Cancellable Task Wrapper
// Convenience for ViewModels — stores and cancels the active fetch task
// so stale requests from deallocated screens don't linger.

final class CancellableTask {
    private var task: Task<Void, Never>?

    /// Replace any running task with a new one.
    func run(_ block: @escaping () async -> Void) {
        task?.cancel()
        task = Task { await block() }
    }

    /// Cancel the current task if one is running.
    func cancel() {
        task?.cancel()
        task = nil
    }

    deinit { cancel() }
}
