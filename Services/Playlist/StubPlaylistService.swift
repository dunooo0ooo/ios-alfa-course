import Foundation

final class StubPlaylistService: PlaylistService, @unchecked Sendable {
    func fetchPlaylistDetail(for playlistId: String) async throws -> PlaylistDetailData? {
        PlaylistDetailData(
            title: "Плейлист \(playlistId)",
            description: "",
            tracks: [],
            coverImageUrl: ""
        )
    }

    func playTrack(at index: Int, in playlistId: String) async throws {}

    func toggleFavorite(for trackId: String) async throws -> Bool {
        false
    }
}
