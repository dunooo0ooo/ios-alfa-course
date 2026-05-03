import Foundation


enum EchoAPIPath {
    static let catalogDemoPostBody = "bdui_catalog_screen"
    static let trackDetailScreen = "409285/bdui-track-detail-screen"
}


protocol EchoAPIServiceProtocol: Sendable {
    func getJSON<T: Decodable>(_ type: T.Type, echoPath: String) async throws -> T
    func postJSON<T: Decodable>(_ body: Data, echoPath: String) async throws -> T
    func putJSON<T: Decodable>(_ body: Data, echoPath: String) async throws -> T

    func url(forEchoPath echoPath: String) -> URL?
}

final class EchoAPIService: EchoAPIServiceProtocol {

    private let client: NetworkClient

    private static let echoJSONHeaders = ["Content-Type": "application/json; charset=utf-8"]

    init(client: NetworkClient = URLSessionNetworkClient()) {
        self.client = client
    }

    func url(forEchoPath echoPath: String) -> URL? {
        let trimmed = echoPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !trimmed.isEmpty else { return nil }
        return URL(string: "https://alfaitmo.ru/server/echo/\(trimmed)")
    }

    func getJSON<T: Decodable>(_ type: T.Type, echoPath: String) async throws -> T {
        guard let url = url(forEchoPath: echoPath) else { throw NetworkError.invalidURL }
        return try await client.get(url)
    }

    func postJSON<T: Decodable>(_ body: Data, echoPath: String) async throws -> T {
        guard let url = url(forEchoPath: echoPath) else { throw NetworkError.invalidURL }
        return try await client.post(url, body: body, headers: Self.echoJSONHeaders)
    }

    func putJSON<T: Decodable>(_ body: Data, echoPath: String) async throws -> T {
        guard let url = url(forEchoPath: echoPath) else { throw NetworkError.invalidURL }
        return try await client.put(url, body: body, headers: Self.echoJSONHeaders)
    }
}
