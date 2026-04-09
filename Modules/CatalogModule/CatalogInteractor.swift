import Foundation
class CatalogInteractor: CatalogInteractorInput {
    var presenter: CatalogInteractorOutput?
    var service: CatalogService?

    private var loadTask: Task<Void, Never>?
    private var lastUserId: String?
    private var cachedItems: [CatalogListItem] = []
    private var searchQuery: String = ""
    private var hasLoadedOnce = false

    func loadCatalog(for userId: String, isRefresh: Bool) {
        lastUserId = userId
        presenter?.catalogDidStartLoading(isRefresh: isRefresh)
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            guard let service = self.service else {
                await MainActor.run {
                    self.cachedItems = []
                    self.hasLoadedOnce = true
                    self.presenter?.catalogServerReturnedNoData()
                }
                return
            }
            do {
                let items = try await service.fetchCatalog(for: userId)
                try Task.checkCancellation()
                let validatedItems = self.validate(items)
                await MainActor.run {
                    self.cachedItems = validatedItems
                    self.hasLoadedOnce = true
                    self.pushFilteredToPresenter()
                }
            } catch is CancellationError {
                await MainActor.run {
                    self.presenter?.catalogRefreshDidCancel()
                }
            } catch {
                await MainActor.run {
                    self.presenter?.catalogLoadFailed(with: error)
                }
            }
        }
    }

    func retryLoadCatalog() {
        guard let id = lastUserId else { return }
        loadCatalog(for: id, isRefresh: false)
    }

    func searchQueryDidChange(_ query: String) {
        searchQuery = query
        guard hasLoadedOnce else { return }
        pushFilteredToPresenter()
    }

    private func pushFilteredToPresenter() {
        let filtered = filter(cachedItems, matching: searchQuery)
        if cachedItems.isEmpty {
            presenter?.catalogServerReturnedNoData()
        } else if filtered.isEmpty {
            presenter?.catalogSearchFilterReturnedNoMatches()
        } else {
            presenter?.catalogDidLoad(filtered)
        }
    }

    private func validate(_ items: [CatalogListItem]) -> [CatalogListItem] {
        items.filter { item in
            !item.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !item.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private func filter(_ items: [CatalogListItem], matching query: String) -> [CatalogListItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return items }

        let normalizedQuery = trimmed.lowercased()
        return items.filter { item in
            item.title.lowercased().contains(normalizedQuery)
                || (item.subtitle?.lowercased().contains(normalizedQuery) ?? false)
                || (item.detailLine?.lowercased().contains(normalizedQuery) ?? false)
                || item.id.lowercased().contains(normalizedQuery)
        }
    }

    func didSelectPlaylist(_ playlistId: String) {
        presenter?.openPlaylistDetail(with: playlistId)
    }

    func didTapLogout() {
        presenter?.openAuthModule()
    }
}
