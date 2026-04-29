import Foundation

class CatalogPresenter: CatalogInteractorOutput {
    weak var view: CatalogView?
    var router: CatalogRouterInput?

    func catalogDidStartLoading(isRefresh: Bool) {
        if isRefresh {
            view?.setRefreshing(true)
        } else {
            view?.render(.loading)
        }
    }

    func catalogDidLoad(_ items: [CatalogListItem]) {
        view?.setRefreshing(false)
        view?.render(.content(makeCatalogNode(from: items)))
    }

    func catalogServerReturnedNoData() {
        view?.setRefreshing(false)
        view?.render(.empty(message: "Нет данных"))
    }

    func catalogSearchFilterReturnedNoMatches() {
        view?.setRefreshing(false)
        view?.render(.empty(message: "Ничего не найдено"))
    }

    func catalogLoadFailed(with error: Error) {
        view?.setRefreshing(false)
        let mapped = (error as? NetworkError) ?? NetworkError.map(error)
        if mapped == .cancelled { return }
        view?.render(.error(message: mapped.userMessage))
    }

    func catalogRefreshDidCancel() {
        view?.setRefreshing(false)
    }

    func openTrackDetail(id: String, title: String, subtitle: String?) {
        router?.openBDUIScreen(configuration: makeTrackScreenConfiguration(
            id: id,
            title: title,
            subtitle: subtitle
        ))
    }

    func openBDUIScreen() {
        router?.openBDUIScreen(configuration: makeCatalogScreenConfiguration())
    }

    func openAuthModule() {
        router?.openAuthModule()
    }

    private func makeCatalogNode(from items: [CatalogListItem]) -> BDUIViewNode {
        let cards: [BDUIViewNode] = items.map { item in
            BDUIViewNode(
                type: .container,
                content: .init(
                    backgroundColor: .surfaceElevated,
                    cornerRadius: .regular,
                    padding: .init(top: .large, leading: .large, bottom: .large, trailing: .large)
                ),
                subviews: [
                    BDUIViewNode(
                        type: .stack,
                        content: .init(axis: .vertical, spacing: .medium, alignment: .fill),
                        subviews: [
                            BDUIViewNode(
                                type: .image,
                                content: .init(
                                    icon: .playlist,
                                    imageURL: item.artworkURL?.absoluteString,
                                    backgroundColor: .surface,
                                    cornerRadius: .large,
                                    width: 220,
                                    height: 220
                                )
                            ),
                            BDUIViewNode(
                                type: .label,
                                content: .init(
                                    text: item.title,
                                    textStyle: .bodyStrong
                                )
                            ),
                            BDUIViewNode(
                                type: .label,
                                content: .init(
                                    text: item.subtitle ?? "",
                                    textStyle: .subheadline
                                )
                            ),
                            BDUIViewNode(
                                type: .button,
                                content: .init(
                                    text: "Открыть",
                                    buttonStyle: .primary,
                                    action: .selectTrack(id: item.id, title: item.title, subtitle: item.subtitle)
                                )
                            )
                        ]
                    )
                ]
            )
        }

        return BDUIViewNode(
            type: .container,
            content: .init(backgroundColor: .clear),
            subviews: [
                BDUIViewNode(
                    type: .stack,
                    content: .init(axis: .vertical, spacing: .large, alignment: .fill),
                    subviews: cards
                )
            ]
        )
    }

    private func makeCatalogScreenConfiguration() -> BDUIScreenConfiguration {
        BDUIScreenConfiguration(
            title: "BDUI Каталог",
            source: .storage(key: "ios-alfa-course-bdui-catalog"),
            fallbackResourceName: "bdui_catalog_screen",
            loadingTitle: "Загружаем BDUI каталог",
            loadingSubtitle: "Получаем длинный экран со скроллом"
        )
    }

    private func makeTrackScreenConfiguration(
        id: String,
        title: String,
        subtitle: String?
    ) -> BDUIScreenConfiguration {
        BDUIScreenConfiguration(
            title: title,
            source: .storage(key: "ios-alfa-course-bdui-track"),
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
