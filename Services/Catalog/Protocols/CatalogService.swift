
protocol CatalogService {
    func fetchCatalog(for userId: String) async throws -> [CatalogListItem]
}
