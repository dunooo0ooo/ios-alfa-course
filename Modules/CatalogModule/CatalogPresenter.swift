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
        router?.openTrackDetail(id: id, title: title, subtitle: subtitle)
    }

    func openBDUIScreen() {
        router?.openBDUIScreen()
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
}
