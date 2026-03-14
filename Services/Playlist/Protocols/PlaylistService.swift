
protocol PlaylistService {
    func fetchPlaylistDetail(for playlistId: String) async throws -> PlaylistDetailData?
    func playTrack(at index: Int, in playlistId: String) async throws
    func toggleFavorite(for trackId: String) async throws -> Bool
}
