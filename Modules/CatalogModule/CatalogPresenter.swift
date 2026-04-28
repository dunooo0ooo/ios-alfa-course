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
        view?.render(.content(makeCellViewModels(from: items)))
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

    private func makeCellViewModels(from items: [CatalogListItem]) -> [PlaylistCellViewModel] {
        items.map { item in
            PlaylistCellViewModel(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                rightText: item.detailLine,
                imageURL: item.artworkURL,
                cellConfiguration: .init(
                    title: item.title,
                    subtitle: item.subtitle,
                    trailingText: item.detailLine,
                    icon: .playlist
                )
            )
        }
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
