import Foundation

struct BDUIScreenConfiguration: Equatable {
    enum Source: Equatable {
        case echo(path: String)
        case echoPost(bodyResourceName: String)
        case storage(key: String)
        case url(URL)
    }

    let title: String
    let source: Source
    let fallbackResourceName: String?
    let loadingTitle: String
    let loadingSubtitle: String
    let templateValues: [String: String]

    init(
        title: String,
        source: Source,
        fallbackResourceName: String? = nil,
        loadingTitle: String = "Загружаем экран",
        loadingSubtitle: String = "Получаем конфиг и строим интерфейс",
        templateValues: [String: String] = [:]
    ) {
        self.title = title
        self.source = source
        self.fallbackResourceName = fallbackResourceName
        self.loadingTitle = loadingTitle
        self.loadingSubtitle = loadingSubtitle
        self.templateValues = templateValues
    }
}
