import Foundation

final class StubPlaylistService: PlaylistService, @unchecked Sendable {
    func fetchPlaylistDetail(for playlistId: String) async throws -> PlaylistDetailData? {
        PlaylistDetailData(
            title: "Плейлист \(playlistId)",
            description: "Демонстрационная подборка",
            tracks: [
                Track(id: "\(playlistId)-1", title: "Midnight Echo", artist: "Neon Rivers", duration: 214, url: "", isFavorite: false),
                Track(id: "\(playlistId)-2", title: "Static Hearts", artist: "Velvet Tape", duration: 187, url: "", isFavorite: false),
                Track(id: "\(playlistId)-3", title: "City Lights", artist: "Analog Kids", duration: 201, url: "", isFavorite: false),
            ],
            coverImageUrl: ""
        )
    }

    func playTrack(at index: Int, in playlistId: String) async throws {}

    func toggleFavorite(for trackId: String) async throws -> Bool {
        false
    }
}
