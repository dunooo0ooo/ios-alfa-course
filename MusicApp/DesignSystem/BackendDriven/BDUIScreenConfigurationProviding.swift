import Foundation

protocol BDUIScreenConfigurationProviding {
    func makeCatalogDemoConfiguration() -> BDUIScreenConfiguration
    func makeTrackDetailConfiguration(id: String, title: String, subtitle: String?) -> BDUIScreenConfiguration
}

struct DefaultBDUIScreenConfigurationProvider: BDUIScreenConfigurationProviding {
    func makeCatalogDemoConfiguration() -> BDUIScreenConfiguration {
        BDUIScreenConfiguration(
            title: "BDUI Каталог",
            source: .echoPost(bodyResourceName: "bdui_catalog_screen"),
            fallbackResourceName: "bdui_catalog_screen",
            loadingTitle: "Загружаем BDUI каталог",
            loadingSubtitle: "Получаем длинный экран со скроллом"
        )
    }

    func makeTrackDetailConfiguration(id: String, title: String, subtitle: String?) -> BDUIScreenConfiguration {
        BDUIScreenConfiguration(
            title: title,
            source: .echoPost(bodyResourceName: "bdui_track_screen"),
            fallbackResourceName: "bdui_track_screen",
            loadingTitle: "Открываем трек",
            loadingSubtitle: "Загружаем экран для выбранного элемента",
            templateValues: [
                "trackId": id,
                "trackTitle": title,
                "trackSubtitle": subtitle ?? "Артист не указан"
            ]
        )
    }
}

