
enum CatalogViewState: Equatable {
    case loading
    case content(sections: [CatalogSection])
    case empty
    case error(message: String)
}
