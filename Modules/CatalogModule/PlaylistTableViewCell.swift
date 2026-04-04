import UIKit

final class PlaylistTableViewCell: UITableViewCell {
    static let reuseIdentifier = "PlaylistTableViewCell"

    private weak var imageLoader: ImageLoading?
    private var rightAccessoryLabel: UILabel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        accessoryType = .disclosureIndicator
        tintColor = DS.Colors.primary
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    required init?(coder: NSCoder) { nil }

    func configure(with viewModel: PlaylistCellViewModel, imageLoader: ImageLoading) {
        self.imageLoader = imageLoader
        imageLoader.cancelLoad(for: self)

        var content = defaultContentConfiguration()
        content.image = DS.Icons.playlist
        content.imageProperties.tintColor = DS.Colors.primary
        content.imageProperties.maximumSize = CGSize(width: 56, height: 56)
        content.text = viewModel.title
        content.secondaryText = viewModel.subtitle
        content.textProperties.font = DS.Typography.bodyStrong()
        content.textProperties.color = DS.Colors.textPrimary
        content.secondaryTextProperties.font = DS.Typography.subheadline()
        content.secondaryTextProperties.color = DS.Colors.textSecondary
        content.textToSecondaryTextVerticalPadding = DS.Spacing.xSmall
        content.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: DS.Spacing.medium,
            leading: DS.Spacing.large,
            bottom: DS.Spacing.medium,
            trailing: DS.Spacing.medium
        )
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
        label.font = DS.Typography.subheadline()
        label.textColor = DS.Colors.textSecondary
        label.textAlignment = .right
        rightAccessoryLabel = label
        return label
    }
}
