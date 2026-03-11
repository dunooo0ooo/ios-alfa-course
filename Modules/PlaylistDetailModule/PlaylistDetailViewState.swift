
enum PlaylistDetailViewState: Equatable {
    case loading
    case content(tracks: [Track], isPlaying: Bool, currentIndex: Int?)
    case empty
    case error(message: String)
}
