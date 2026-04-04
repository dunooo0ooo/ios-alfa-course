import Foundation
import UIKit

class PlaylistDetailInteractor: PlaylistDetailInteractorInput {
    var presenter: PlaylistDetailInteractorOutput?
    var service: PlaylistService?
    private var currentCollectionId: String?

    func loadTracks(for playlistId: String) {
        currentCollectionId = playlistId
        Task {
            do {
                guard let service else {
                    await MainActor.run {
                        presenter?.tracksLoadFailed(with: NSError(domain: "Playlist", code: -1))
                    }
                    return
                }
                let data = try await service.fetchPlaylistDetail(for: playlistId)
                let tracks = data?.tracks ?? []
                await MainActor.run {
                    presenter?.tracksDidLoaded(tracks, currentIndex: tracks.isEmpty ? nil : 0)
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
                try await service?.playTrack(at: index, in: currentCollectionId ?? "")
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
