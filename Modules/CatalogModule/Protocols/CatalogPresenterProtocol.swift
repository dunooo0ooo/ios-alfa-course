protocol CatalogPresenterOutput: AnyObject {
    func didSelectPlaylist(_ playlistId: String)
    func didLogout()
}
