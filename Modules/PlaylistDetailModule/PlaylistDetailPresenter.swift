
class PlaylistDetailPresenter: PlaylistDetailPresenterInput {
    weak var view: PlaylistDetailView?
    var router: PlaylistDetailRouterInput?
    var interactor: PlaylistDetailInteractorInput?

    func didLoad(playlistId: String) {
        view?.render(.loading)
        interactor?.loadTracks(for: playlistId)
    }

    func didTapTrack(at index: Int) {
        interactor?.playTrack(at: index)
    }

    func didToggleFavorite(for trackId: String) {
        interactor?.toggleFavorite(for: trackId)
    }

    func didTapBack() {
        router?.navigateBack()
    }
}
