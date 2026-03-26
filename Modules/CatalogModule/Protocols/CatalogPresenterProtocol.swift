
protocol CatalogPresenterInput {
    func didLoad(userId: String)
    func didSelectPlaylist(_ playlistId: String)
    func didTapLogout()
}

protocol CatalogPresenterOutput: AnyObject {
    func didSelectPlaylist(_ playlistId: String)
    func didLogout()
}
