
protocol CatalogInteractorInput {
    func loadCatalog(for userId: String, isRefresh: Bool)
    func retryLoadCatalog()
    func searchQueryDidChange(_ query: String)
    func didSelectTrack()
    func didTapOpenBDUIDemo()
    func didTapLogout()
}

protocol CatalogInteractorOutput: AnyObject {
    func catalogDidStartLoading(isRefresh: Bool)
    func catalogDidLoad(_ items: [CatalogListItem])
    func catalogServerReturnedNoData()
    func catalogSearchFilterReturnedNoMatches()
    func catalogLoadFailed(with error: Error)
    func catalogRefreshDidCancel()
    func openTrackDetail()
    func openBDUIScreen()
    func openAuthModule()
}
