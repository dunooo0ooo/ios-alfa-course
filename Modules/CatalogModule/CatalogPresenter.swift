
class CatalogPresenter: CatalogPresenterInput {
    weak var view: CatalogView?
    var router: CatalogRouterInput?
    var interactor: CatalogInteractorInput?

    func didLoad(userId: String) {
        view?.render(.loading)
        interactor?.loadCatalog(for: userId)
    }

    func didSelectPlaylist(_ playlistId: String) {
        router?.openPlaylistDetail(with: playlistId)
    }

    func didTapLogout() {
        router?.openAuthModule()
    }
}
