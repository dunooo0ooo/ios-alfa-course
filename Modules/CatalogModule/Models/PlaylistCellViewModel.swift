import Foundation

struct PlaylistCellViewModel: Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String?
    let rightText: String?
    let imageURL: URL?
    let cellConfiguration: DSListItemCellViewModel
}
