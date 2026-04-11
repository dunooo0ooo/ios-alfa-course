import UIKit

final class DSStateView: UIView {
    enum State {
        case loading(title: String, subtitle: String?)
        case empty(title: String, subtitle: String?)
        case error(title: String, subtitle: String?, actionTitle: String)
    }

    var actionHandler: (() -> Void)?

    private let iconView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let actionButton = DSButton()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { nil }

    func render(_ state: State) {
        switch state {
        case .loading(let title, let subtitle):
            iconView.isHidden = true
            activityIndicator.startAnimating()
            titleLabel.text = title
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = subtitle == nil
            actionButton.configure(.init(title: "Повторить", style: .secondary))
            actionButton.isHidden = true
        case .empty(let title, let subtitle):
            iconView.isHidden = false
            iconView.image = DS.Icons.empty
            activityIndicator.stopAnimating()
            titleLabel.text = title
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = subtitle == nil
            actionButton.configure(.init(title: "Повторить", style: .secondary))
            actionButton.isHidden = true
        case .error(let title, let subtitle, let actionTitle):
            iconView.isHidden = false
            iconView.image = DS.Icons.error
            activityIndicator.stopAnimating()
            titleLabel.text = title
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = subtitle == nil
            actionButton.configure(.init(title: actionTitle, style: .secondary))
            actionButton.isHidden = false
        }
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = DS.Colors.background

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = DS.Colors.textSecondary
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = DS.Colors.primary
        activityIndicator.hidesWhenStopped = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.apply(.screenTitle)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.apply(.body)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = DS.Spacing.medium
        stackView.alignment = .center

        actionButton.configure(.init(title: "Повторить", style: .secondary))
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        actionButton.isHidden = true

        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(activityIndicator)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.addArrangedSubview(actionButton)

        addSubview(stackView)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: DS.Spacing.xLarge),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -DS.Spacing.xLarge),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 160),
        ])
    }

    @objc private func actionTapped() {
        actionHandler?()
    }
}
