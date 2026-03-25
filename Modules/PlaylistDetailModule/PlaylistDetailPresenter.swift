import UIKit

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

extension PlaylistDetailPresenter: PlaylistDetailInteractorOutput {
    func tracksDidLoaded(_ tracks: [Track], currentIndex: Int?) {
        if tracks.isEmpty {
            view?.render(.empty)
        } else {
            view?.render(.content(tracks: tracks, isPlaying: false, currentIndex: currentIndex))
        }
    }

    func tracksLoadFailed(with error: Error) {
        view?.render(.error(message: error.localizedDescription))
    }

    func playbackStarted(at index: Int) {
        // UI обновим
        _ = index
    }

    func favoriteToggled(for trackId: String, isFavorite: Bool) {
        _ = (trackId, isFavorite)
    }
}
