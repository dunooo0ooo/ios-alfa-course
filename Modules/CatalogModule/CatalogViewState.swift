
enum CatalogViewState: Equatable {
    case idle
    case loading
    case content(BDUIViewNode)
    case empty(message: String)
    case error(message: String)
}
