import Foundation

class CatalogPresenter: CatalogInteractorOutput {
    weak var view: CatalogView?
    var router: CatalogRouterInput?
    var bduiConfigurationProvider: BDUIScreenConfigurationProviding = DefaultBDUIScreenConfigurationProvider()

    func catalogDidStartLoading(isRefresh: Bool) {
        if isRefresh {
            view?.setRefreshing(true)
        } else {
            view?.render(.loading)
        }
    }

    func catalogDidLoad(_ items: [CatalogListItem]) {
        view?.setRefreshing(false)
        view?.render(.content(makeListViewModels(from: items)))
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

    func openTrackDetail() {
        router?.openBDUIScreen(configuration: bduiConfigurationProvider.makeTrackDetailConfiguration())
    }

    func openBDUIScreen() {
        router?.openBDUIScreen(configuration: bduiConfigurationProvider.makeCatalogDemoConfiguration())
    }

    func openAuthModule() {
        router?.openAuthModule()
    }

    private func makeListViewModels(from items: [CatalogListItem]) -> [PlaylistCellViewModel] {
        items.map { item in
            PlaylistCellViewModel(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                rightText: item.detailLine,
                imageURL: item.artworkURL,
                cellConfiguration: DSListItemCellViewModel(
                    title: item.title,
                    subtitle: item.subtitle,
                    trailingText: item.detailLine,
                    icon: .playlist,
                    imageURL: item.artworkURL
                )
            )
        }
    }
}
