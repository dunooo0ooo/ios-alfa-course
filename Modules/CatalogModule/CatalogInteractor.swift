
class CatalogInteractor: CatalogInteractorInput {
    var presenter: CatalogInteractorOutput?
    var service: CatalogService?

    private var loadTask: Task<Void, Never>?

    func loadCatalog(for userId: String) {
        presenter?.catalogDidStartLoading()
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            guard let service = self.service else {
                await MainActor.run {
                    self.presenter?.catalogDidLoad([])
                }
                return
            }
            do {
                let items = try await service.fetchCatalog(for: userId)
                try Task.checkCancellation()
                let viewModels = items.map { PlaylistCellViewModel(item: $0) }
                await MainActor.run {
                    self.presenter?.catalogDidLoad(viewModels)
                }
            } catch is CancellationError {
                return
            } catch {
                await MainActor.run {
                    self.presenter?.catalogLoadFailed(with: error)
                }
            }
        }
    }

    func didSelectPlaylist(_ playlistId: String) {
        presenter?.openPlaylistDetail(with: playlistId)
    }

    func didTapLogout() {
        presenter?.openAuthModule()
    }
}
