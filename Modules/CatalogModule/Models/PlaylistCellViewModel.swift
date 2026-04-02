import Foundation

struct PlaylistCellViewModel: Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String?
    let rightText: String?
    let imageURL: URL?

    init(id: String, title: String, subtitle: String?, rightText: String?, imageURL: URL?) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.rightText = rightText
        self.imageURL = imageURL
    }

    init(item: CatalogListItem) {
        self.init(
            id: item.id,
            title: item.title,
            subtitle: item.subtitle,
            rightText: item.detailLine,
            imageURL: item.artworkURL
        )
    }
}
