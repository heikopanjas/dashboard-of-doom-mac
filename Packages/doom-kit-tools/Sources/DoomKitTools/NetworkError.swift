import Foundation

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case noData
    case decodingError(error: Error)
    case networkUnavailable
    case taskCancelled
    case timeout
}
