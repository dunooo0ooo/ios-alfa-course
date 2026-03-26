
protocol CatalogInteractorInput {
    func loadCatalog(for userId: String)
}

protocol CatalogInteractorOutput: AnyObject {
    func catalogDidLoaded(_ sections: [CatalogSection])
    func catalogLoadFailed(with error: Error)
}
