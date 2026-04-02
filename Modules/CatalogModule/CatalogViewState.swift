
enum CatalogViewState: Equatable {
    case idle
    case loading
    case content([PlaylistCellViewModel])
    case empty
    case error(message: String)
}
