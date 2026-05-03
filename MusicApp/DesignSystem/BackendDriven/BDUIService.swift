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
    private let echoAPI: EchoAPIServiceProtocol
    private let fetchPolicy: FetchPolicy

    init(
        networkClient: NetworkClient = URLSessionNetworkClient(),
        echoAPIService: EchoAPIServiceProtocol? = nil,
        fetchPolicy: FetchPolicy = .remoteFirst
    ) {
        self.networkClient = networkClient
        self.echoAPI = echoAPIService ?? EchoAPIService(client: networkClient)
        self.fetchPolicy = fetchPolicy
    }

    func fetchScreen(configuration: BDUIScreenConfiguration) async throws -> BDUIViewNode {
        if fetchPolicy == .bundleFirst, let fallback = loadFallbackScreen(named: configuration.fallbackResourceName) {
            return applyTemplateValuesIfNeeded(fallback, configuration: configuration)
        }

        do {
            let node: BDUIViewNode
            switch configuration.source {
            case .echo(let path):
                node = try await echoAPI.getJSON(BDUIViewNode.self, echoPath: path)
            case .echoPost(let bodyResourceName):
                let json = try loadBundledJSON(named: bodyResourceName)
                let body = Data(json.utf8)
                node = try await echoAPI.postJSON(body, echoPath: bodyResourceName)
            case .storage(let key):
                guard let url = makeStorageURL(key: key) else { throw NetworkError.invalidURL }
                let response: StorageResponse<BDUIViewNode> = try await networkClient.get(url)
                node = response.value
            case .url(let url):
                node = try await networkClient.get(url)
            }
            return applyTemplateValuesIfNeeded(node, configuration: configuration)
        } catch {
            if let fallback = loadFallbackScreen(named: configuration.fallbackResourceName) {
                return applyTemplateValuesIfNeeded(fallback, configuration: configuration)
            }
            throw error
        }
    }

    /// Подстановка `{{ключ}}` выполняется только если в конфигурации заданы `templateValues`; иначе узел не трогаем (например экран трека целиком из Echo GET).
    private func applyTemplateValuesIfNeeded(
        _ node: BDUIViewNode,
        configuration: BDUIScreenConfiguration
    ) -> BDUIViewNode {
        guard !configuration.templateValues.isEmpty else { return node }
        return node.applying(templateValues: configuration.templateValues)
    }

    private func makeStorageURL(key: String) -> URL? {
        guard let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        return URL(string: "https://alfa-itmo.ru/server/v1/storage/\(encodedKey)")
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
