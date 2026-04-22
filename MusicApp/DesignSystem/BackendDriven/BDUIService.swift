import Foundation

protocol BDUIScreenProviding {
    func fetchScreen(path: String) async throws -> BDUIViewNode
}

final class EchoBDUIService: BDUIScreenProviding {
    enum FetchPolicy {
        case bundleFirst
        case remoteFirst
    }

    private let networkClient: NetworkClient
    private let fallbackResourceName: String
    private let fetchPolicy: FetchPolicy

    init(
        networkClient: NetworkClient = URLSessionNetworkClient(),
        fallbackResourceName: String = "bdui_demo_screen",
        fetchPolicy: FetchPolicy = .remoteFirst
    ) {
        self.networkClient = networkClient
        self.fallbackResourceName = fallbackResourceName
        self.fetchPolicy = fetchPolicy
    }

    func fetchScreen(path: String) async throws -> BDUIViewNode {
        if fetchPolicy == .bundleFirst, let fallback = loadFallbackScreen() {
            return fallback
        }

        var allowedCharacters = CharacterSet.urlPathAllowed
        allowedCharacters.remove(charactersIn: "/")
        guard let encodedPath = path.addingPercentEncoding(withAllowedCharacters: allowedCharacters),
              let url = URL(string: "https://alfaitmo.ru/server/echo/\(encodedPath)") else {
            throw NetworkError.invalidURL
        }

        do {
            return try await networkClient.get(url)
        } catch {
            if let fallback = loadFallbackScreen() {
                return fallback
            }
            throw error
        }
    }

    private func loadFallbackScreen() -> BDUIViewNode? {
        guard let url = Bundle.main.url(forResource: fallbackResourceName, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return makeInlineFallbackScreen()
        }
        return (try? JSONDecoder().decode(BDUIViewNode.self, from: data)) ?? makeInlineFallbackScreen()
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
