
protocol PlaylistDetailInteractorInput {
    func loadTracks(for playlistId: String)
    func playTrack(at index: Int)
    func toggleFavorite(for trackId: String)
}

protocol PlaylistDetailInteractorOutput: AnyObject {
    func tracksDidLoaded(_ tracks: [Track], currentIndex: Int?)
    func tracksLoadFailed(with error: Error)
    func playbackStarted(at index: Int)
    func favoriteToggled(for trackId: String, isFavorite: Bool)
}
