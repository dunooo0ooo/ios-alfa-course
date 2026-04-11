import UIKit

class PlaylistDetailPresenter: PlaylistDetailPresenterInput {
    weak var view: PlaylistDetailView?
    var router: PlaylistDetailRouterInput?
    var interactor: PlaylistDetailInteractorInput?
    private var tracks: [Track] = []
    private var currentIndex: Int?
    private var isPlaying = false

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
            self.tracks = tracks
            self.currentIndex = currentIndex ?? 0
            isPlaying = false
            view?.render(.content(tracks: tracks, isPlaying: isPlaying, currentIndex: self.currentIndex))
        }
    }

    func tracksLoadFailed(with error: Error) {
        view?.render(.error(message: error.localizedDescription))
    }

    func playbackStarted(at index: Int) {
        guard tracks.indices.contains(index) else { return }
        currentIndex = index
        isPlaying = true
        view?.render(.content(tracks: tracks, isPlaying: isPlaying, currentIndex: currentIndex))
    }

    func favoriteToggled(for trackId: String, isFavorite: Bool) {
        guard let index = tracks.firstIndex(where: { $0.id == trackId }) else { return }
        tracks[index].isFavorite = isFavorite
        view?.render(.content(tracks: tracks, isPlaying: isPlaying, currentIndex: currentIndex))
    }
}
