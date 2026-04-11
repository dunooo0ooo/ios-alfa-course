protocol CatalogPresenterOutput: AnyObject {
    func didSelectTrack(id: String, title: String, subtitle: String?)
    func didLogout()
}
