import Foundation

protocol BDUIScreenConfigurationProviding {
    func makeCatalogDemoConfiguration() -> BDUIScreenConfiguration
    func makeTrackDetailConfiguration() -> BDUIScreenConfiguration
}

struct DefaultBDUIScreenConfigurationProvider: BDUIScreenConfigurationProviding {
    func makeCatalogDemoConfiguration() -> BDUIScreenConfiguration {
        BDUIScreenConfiguration(
            title: "BDUI Каталог",
            source: .echoPost(bodyResourceName: EchoAPIPath.catalogDemoPostBody),
            fallbackResourceName: "bdui_catalog_screen",
            loadingTitle: "Загружаем BDUI каталог",
            loadingSubtitle: "Получаем длинный экран со скроллом"
        )
    }

    func makeTrackDetailConfiguration() -> BDUIScreenConfiguration {
        BDUIScreenConfiguration(title: "", source: .echo(path: EchoAPIPath.trackDetailScreen))
    }
}

