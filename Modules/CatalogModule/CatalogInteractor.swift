
class CatalogInteractor: CatalogInteractorInput {
    var presenter: CatalogInteractorOutput?
    var service: CatalogService?

    func loadCatalog(for userId: String) {
        Task {
            do {
                let sections = try await service?.fetchCatalog(for: userId)
                await MainActor.run {
                    presenter?.catalogDidLoaded(sections ?? [])
                }
            } catch {
                await MainActor.run {
                    presenter?.catalogLoadFailed(with: error)
                }
            }
        }
    }
}
