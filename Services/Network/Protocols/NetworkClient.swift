import Foundation

protocol NetworkClient: Sendable {
    func get<T: Decodable>(_ url: URL) async throws -> T
}
