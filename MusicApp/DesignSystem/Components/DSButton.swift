import UIKit

final class DSButton: UIButton {
    enum Style: Equatable {
        case primary
        case secondary
    }

    struct Configuration: Equatable {
        let title: String
        let style: Style
        let isEnabled: Bool
        let isLoading: Bool

        init(
            title: String,
            style: Style,
            isEnabled: Bool = true,
            isLoading: Bool = false
        ) {
            self.title = title
            self.style = style
            self.isEnabled = isEnabled
            self.isLoading = isLoading
        }
    }

    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var currentConfiguration = Configuration(title: "", style: .primary)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { nil }

    convenience init(configuration: Configuration) {
        self.init(frame: .zero)
        configure(configuration)
    }

    func configure(_ configuration: Configuration) {
        currentConfiguration = configuration
        applyConfiguration()
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = DS.Spacing.cornerRadius
        layer.cornerCurve = .continuous
        titleLabel?.font = DS.Typography.button()
        heightAnchor.constraint(equalToConstant: DS.Spacing.buttonHeight).isActive = true

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        applyConfiguration()
    }

    private func applyConfiguration() {
        isEnabled = currentConfiguration.isEnabled

        switch currentConfiguration.style {
        case .primary:
            backgroundColor = currentConfiguration.isEnabled
                ? DS.Colors.primary
                : DS.Colors.primary.withAlphaComponent(0.45)
            setTitleColor(DS.Colors.textOnPrimary, for: .normal)
            layer.borderWidth = 0
            layer.borderColor = nil
        case .secondary:
            backgroundColor = DS.Colors.surface
            setTitleColor(
                currentConfiguration.isEnabled ? DS.Colors.primary : DS.Colors.textSecondary,
                for: .normal
            )
            layer.borderWidth = 1
            layer.borderColor = DS.Colors.border.cgColor
        }

        alpha = currentConfiguration.isEnabled ? 1 : 0.72

        if currentConfiguration.isLoading {
            super.setTitle(nil, for: .normal)
            activityIndicator.startAnimating()
            isUserInteractionEnabled = false
        } else {
            super.setTitle(currentConfiguration.title, for: .normal)
            activityIndicator.stopAnimating()
            isUserInteractionEnabled = currentConfiguration.isEnabled
        }
    }
}
