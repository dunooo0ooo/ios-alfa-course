class CatalogPresenter: CatalogInteractorOutput {
    weak var view: CatalogView?
    var router: CatalogRouterInput?

    func catalogDidStartLoading() {
        view?.render(.loading)
    }

    func catalogDidLoad(_ items: [PlaylistCellViewModel]) {
        if items.isEmpty {
            view?.render(.empty)
        } else {
            view?.render(.content(items))
        }
    }

    func catalogLoadFailed(with error: Error) {
        let mapped = (error as? NetworkError) ?? NetworkError.map(error)
        if mapped == .cancelled { return }
        view?.render(.error(message: mapped.userMessage))
    }

    func openPlaylistDetail(with playlistId: String) {
        router?.openPlaylistDetail(with: playlistId)
    }

    func openAuthModule() {
        router?.openAuthModule()
    }
}
