import Foundation

// MARK: - Echo API paths (ключи Echo, без доменной логики клиента)

enum EchoAPIPath {
    /// POST с телом из `bdui_catalog_screen.json` (демо каталог в BDUI).
    static let catalogDemoPostBody = "bdui_catalog_screen"
    /// Последний сохранённый на Echo JSON экрана детали трека (читаем GET перед отрисовкой).
    static let trackDetailScreen = "409285/bdui-track-detail-screen"
}

/// Только HTTP-слой к `GET/POST/PUT …/server/echo/{echoPath}` по спецификации Echo.
protocol EchoAPIServiceProtocol: Sendable {
    func getJSON<T: Decodable>(_ type: T.Type, echoPath: String) async throws -> T
    func postJSON<T: Decodable>(_ body: Data, echoPath: String) async throws -> T
    func putJSON<T: Decodable>(_ body: Data, echoPath: String) async throws -> T

    func url(forEchoPath echoPath: String) -> URL?
}

/// Когда отправлять JSON для экрана трека на Echo (**PUT/POST**) и когда его забирать (**GET**):
/// - **Публикация (PUT или POST)** — отдельный шаг до использования приложения: скрипт, Postman,
///   админка курса или разовый вызов из кода разработки. По этому пути сохраняется дерево BDUI JSON.
/// - **Отрисовка у пользователя** — при переходе на экран приложение выполняет **только GET** по тому же
///   `echoPath` и декодирует ответ в `BDUIViewNode`. Если по пути ещё ничего не положили, будет 404 —
///   тогда помогает `fallbackResourceName`, если он задан в конфигурации BDUI.
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
