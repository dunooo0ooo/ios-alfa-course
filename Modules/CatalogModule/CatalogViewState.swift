
enum CatalogViewState: Equatable {
    case idle
    case loading
    case content([PlaylistCellViewModel])
    case empty(message: String)
    case error(message: String)
}
