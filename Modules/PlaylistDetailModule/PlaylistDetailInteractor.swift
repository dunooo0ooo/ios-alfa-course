
class PlaylistDetailInteractor: PlaylistDetailInteractorInput {
    var presenter: PlaylistDetailInteractorOutput?
    var service: PlaylistService?

    func loadTracks(for playlistId: String) {
        Task {
            do {
                let data = try await service?.fetchPlaylistDetail(for: playlistId)
                guard let tracks = data?.tracks else { return }
                await MainActor.run {
                    presenter?.tracksDidLoaded(tracks, currentIndex: nil)
                }
            } catch {
                await MainActor.run {
                    presenter?.tracksLoadFailed(with: error)
                }
            }
        }
    }

    func playTrack(at index: Int) {
        Task {
            do {
                try await service?.playTrack(at: index, in: "playlistId")
                await MainActor.run {
                    presenter?.playbackStarted(at: index)
                }
            } catch {
                // Обработка ошибки воспроизведения
            }
        }
    }

    func toggleFavorite(for trackId: String) {
        Task {
            do {
                let isFavorite = try await service?.toggleFavorite(for: trackId)
                await MainActor.run {
                    presenter?.favoriteToggled(for: trackId, isFavorite: isFavorite ?? false)
                }
            } catch {
                // Обработка ошибки
            }
        }
    }
}
