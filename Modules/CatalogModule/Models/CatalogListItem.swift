import Foundation

struct CatalogListItem: Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String?
    let detailLine: String?
    let artworkURL: URL?
}
