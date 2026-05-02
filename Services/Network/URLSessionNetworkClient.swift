import Foundation

final class URLSessionNetworkClient: NetworkClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = URLSessionNetworkClient.makeDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }

    private static func makeDecoder() -> JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .useDefaultKeys
        return d
    }

    func get<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.setValue("MusicApp/1.0 (iOS course)", forHTTPHeaderField: "User-Agent")

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.map(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200 ..< 300).contains(http.statusCode) else {
            throw NetworkError.httpStatus(code: http.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    func post<T: Decodable>(_ url: URL, body: Data, headers: [String: String] = [:]) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.timeoutInterval = 30
        request.setValue("MusicApp/1.0 (iOS course)", forHTTPHeaderField: "User-Agent")
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.map(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200 ..< 300).contains(http.statusCode) else {
            throw NetworkError.httpStatus(code: http.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
