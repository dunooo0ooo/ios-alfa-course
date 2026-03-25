
protocol CatalogInteractorInput {
    func loadCatalog(for userId: String)
    func didSelectPlaylist(_ playlistId: String)
    func didTapLogout()
}

protocol CatalogInteractorOutput: AnyObject {
    func catalogDidStartLoading()
    func catalogDidLoad(_ items: [PlaylistCellViewModel])
    func catalogLoadFailed(with error: Error)
    func openPlaylistDetail(with playlistId: String)
    func openAuthModule()
}
