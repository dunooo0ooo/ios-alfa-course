import Foundation

protocol NetworkClient: Sendable {
    func get<T: Decodable>(_ url: URL) async throws -> T
    func post<T: Decodable>(_ url: URL, body: Data, headers: [String: String]) async throws -> T
    func put<T: Decodable>(_ url: URL, body: Data, headers: [String: String]) async throws -> T
}
