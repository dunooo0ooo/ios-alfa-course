import UIKit

struct DSListItemCellViewModel: Equatable, Sendable {
    enum Icon: Equatable, Sendable {
        case playlist
    }

    let title: String
    let subtitle: String?
    let trailingText: String?
    let icon: Icon
    let imageURL: URL?

    init(
        title: String,
        subtitle: String?,
        trailingText: String?,
        icon: Icon,
        imageURL: URL? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailingText = trailingText
        self.icon = icon
        self.imageURL = imageURL
    }
}

class DSListItemCell: UITableViewCell {
    static let reuseIdentifier = "DSListItemCell"

    private var trailingLabel: UILabel?
    private var imageLoader: ImageLoading?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        accessoryType = .disclosureIndicator
        tintColor = DS.Colors.primary
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    required init?(coder: NSCoder) { nil }

    func configure(with viewModel: DSListItemCellViewModel, imageLoader: ImageLoading?) {
        self.imageLoader = imageLoader

        var content = defaultContentConfiguration()
        content.image = image(for: viewModel.icon)
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

        imageLoader?.loadImage(from: viewModel.imageURL, bindTo: self) { [weak self] image in
            guard let self else { return }
            guard var updated = self.contentConfiguration as? UIListContentConfiguration else { return }
            if let image {
                updated.image = image
                updated.imageProperties.tintColor = nil
            } else {
                updated.image = self.image(for: viewModel.icon)
                updated.imageProperties.tintColor = DS.Colors.primary
            }
            updated.imageProperties.maximumSize = CGSize(width: 56, height: 56)
            self.contentConfiguration = updated
        }

        if let trailingText = viewModel.trailingText, !trailingText.isEmpty {
            let label = trailingLabel ?? makeTrailingLabel()
            label.text = trailingText
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

    private func image(for icon: DSListItemCellViewModel.Icon) -> UIImage? {
        switch icon {
        case .playlist:
            return DS.Icons.playlist
        }
    }

    private func makeTrailingLabel() -> UILabel {
        let label = UILabel()
        label.font = DS.Typography.subheadline()
        label.textColor = DS.Colors.textSecondary
        label.textAlignment = .right
        trailingLabel = label
        return label
    }
}
