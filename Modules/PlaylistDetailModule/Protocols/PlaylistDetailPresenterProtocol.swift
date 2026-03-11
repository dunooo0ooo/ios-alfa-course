
protocol PlaylistDetailPresenterInput {
    func didLoad(playlistId: String)
    func didTapTrack(at index: Int)
    func didToggleFavorite(for trackId: String)
    func didTapBack()
}

protocol PlaylistDetailPresenterOutput: AnyObject {
    func didNavigateBack()
    func didPlayTrack(at index: Int)
    func didToggleFavorite(for trackId: String)
}
