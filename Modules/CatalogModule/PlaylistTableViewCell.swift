import UIKit

final class PlaylistTableViewCell: UITableViewCell {
    static let reuseIdentifier = "PlaylistTableViewCell"

    private weak var imageLoader: ImageLoading?
    private var rightAccessoryLabel: UILabel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        accessoryType = .disclosureIndicator
    }

    required init?(coder: NSCoder) { nil }

    func configure(with viewModel: PlaylistCellViewModel, imageLoader: ImageLoading) {
        self.imageLoader = imageLoader
        imageLoader.cancelLoad(for: self)

        var content = defaultContentConfiguration()
        content.image = UIImage(systemName: "music.note.list")
        content.imageProperties.tintColor = .secondaryLabel
        content.imageProperties.maximumSize = CGSize(width: 56, height: 56)
        content.text = viewModel.title
        content.secondaryText = viewModel.subtitle
        content.textProperties.font = UIFont.preferredFont(forTextStyle: .headline)
        content.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .subheadline)
        content.secondaryTextProperties.color = .secondaryLabel
        content.textToSecondaryTextVerticalPadding = 4
        content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 12)
        contentConfiguration = content

        if let rightText = viewModel.rightText, !rightText.isEmpty {
            let label = rightAccessoryLabel ?? makeRightAccessoryLabel()
            label.text = rightText
            accessoryView = label
        } else {
            accessoryView = nil
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoader?.cancelLoad(for: self)
        contentConfiguration = nil
        accessoryView = nil
    }

    private func makeRightAccessoryLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        rightAccessoryLabel = label
        return label
    }
}
