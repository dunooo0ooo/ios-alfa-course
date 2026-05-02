import Foundation

protocol BDUIScreenProviding {
    func fetchScreen(configuration: BDUIScreenConfiguration) async throws -> BDUIViewNode
}

final class RemoteBDUIScreenService: BDUIScreenProviding {
    private struct StorageResponse<T: Decodable>: Decodable {
        let value: T
    }

    enum FetchPolicy {
        case bundleFirst
        case remoteFirst
    }

    private let networkClient: NetworkClient
    private let fetchPolicy: FetchPolicy

    init(
        networkClient: NetworkClient = URLSessionNetworkClient(),
        fetchPolicy: FetchPolicy = .remoteFirst
    ) {
        self.networkClient = networkClient
        self.fetchPolicy = fetchPolicy
    }

    func fetchScreen(configuration: BDUIScreenConfiguration) async throws -> BDUIViewNode {
        if fetchPolicy == .bundleFirst, let fallback = loadFallbackScreen(named: configuration.fallbackResourceName) {
            return fallback.applying(templateValues: configuration.templateValues)
        }

        guard let url = makeURL(for: configuration.source) else {
            throw NetworkError.invalidURL
        }

        do {
            let node: BDUIViewNode
            switch configuration.source {
            case .echo:
                node = try await networkClient.get(url)
            case .echoPost(let bodyResourceName):
                let json = try loadBundledJSON(named: bodyResourceName)
                    .applying(templateValues: configuration.templateValues)
                let body = Data(json.utf8)
                node = try await networkClient.post(
                    url,
                    body: body,
                    headers: ["Content-Type": "application/json; charset=utf-8"]
                )
            case .storage:
                let response: StorageResponse<BDUIViewNode> = try await networkClient.get(url)
                node = response.value
            case .url:
                node = try await networkClient.get(url)
            }
            return node.applying(templateValues: configuration.templateValues)
        } catch {
            if let fallback = loadFallbackScreen(named: configuration.fallbackResourceName) {
                return fallback.applying(templateValues: configuration.templateValues)
            }
            throw error
        }
    }

    private func makeURL(for source: BDUIScreenConfiguration.Source) -> URL? {
        switch source {
        case .echo(let path):
            var allowedCharacters = CharacterSet.urlPathAllowed
            allowedCharacters.remove(charactersIn: "/")
            guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
                return nil
            }
            return URL(string: "https://alfaitmo.ru/server/echo/\(encodedPath)")
        case .echoPost(let bodyResourceName):
            var allowedCharacters = CharacterSet.urlPathAllowed
            allowedCharacters.remove(charactersIn: "/")
            guard let encodedPath = bodyResourceName.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
                return nil
            }
            return URL(string: "https://alfaitmo.ru/server/echo/\(encodedPath)")
        case .storage(let key):
            guard let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
                return nil
            }
            return URL(string: "https://alfa-itmo.ru/server/v1/storage/\(encodedKey)")
        case .url(let url):
            return url
        }
    }

    private func loadFallbackScreen(named resourceName: String?) -> BDUIViewNode? {
        guard let resourceName,
              let url = Bundle.main.url(forResource: resourceName, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return makeInlineFallbackScreen()
        }
        return (try? JSONDecoder().decode(BDUIViewNode.self, from: data)) ?? makeInlineFallbackScreen()
    }

    private func loadBundledJSON(named resourceName: String) throws -> String {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json") else {
            throw NetworkError.invalidResponse
        }
        let data = try Data(contentsOf: url)
        guard let json = String(data: data, encoding: .utf8) else {
            throw NetworkError.decodingFailed
        }
        return json
    }

    private func makeInlineFallbackScreen() -> BDUIViewNode {
        BDUIViewNode(
            type: .container,
            content: .init(
                backgroundColor: .clear,
                padding: .init(top: .large, leading: .large, bottom: .large, trailing: .large)
            ),
            subviews: [
                BDUIViewNode(
                    type: .stack,
                    content: .init(axis: .vertical, spacing: .large, alignment: .fill),
                    subviews: [
                        BDUIViewNode(
                            type: .image,
                            content: .init(
                                icon: .playlist,
                                backgroundColor: .primary,
                                cornerRadius: .large,
                                width: 180,
                                height: 180
                            )
                        ),
                        BDUIViewNode(
                            type: .label,
                            content: .init(
                                text: "Backend Driven UI",
                                textStyle: .heroTitle
                            )
                        ),
                        BDUIViewNode(
                            type: .label,
                            content: .init(
                                text: "Экран собран из декодируемой JSON-модели и generic mapper.",
                                textStyle: .body
                            )
                        ),
                        BDUIViewNode(
                            type: .button,
                            content: .init(
                                text: "Вывести action в консоль",
                                buttonStyle: .primary,
                                action: .print(message: "BDUI button tapped")
                            )
                        ),
                        BDUIViewNode(
                            type: .button,
                            content: .init(
                                text: "Перезагрузить экран",
                                buttonStyle: .secondary,
                                action: .reload
                            )
                        )
                    ]
                )
            ]
        )
    }
}

typealias EchoBDUIService = RemoteBDUIScreenService
