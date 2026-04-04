import UIKit

final class DSButton: UIButton {
    enum Style {
        case primary
        case secondary
    }

    private let style: Style
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var storedTitle: String?

    var isLoading: Bool = false {
        didSet { updateLoadingState() }
    }

    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        configureAppearance()
    }

    required init?(coder: NSCoder) { nil }

    override var isEnabled: Bool {
        didSet { updateEnabledAppearance() }
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        if state == .normal {
            storedTitle = title
        }
        super.setTitle(title, for: state)
    }

    private func configureAppearance() {
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

        updateEnabledAppearance()
    }

    private func updateEnabledAppearance() {
        switch style {
        case .primary:
            backgroundColor = isEnabled ? DS.Colors.primary : DS.Colors.primary.withAlphaComponent(0.45)
            setTitleColor(DS.Colors.textOnPrimary, for: .normal)
        case .secondary:
            backgroundColor = DS.Colors.surface
            layer.borderWidth = 1
            layer.borderColor = DS.Colors.border.cgColor
            setTitleColor(isEnabled ? DS.Colors.primary : DS.Colors.textSecondary, for: .normal)
        }

        alpha = isEnabled ? 1 : 0.72
    }

    private func updateLoadingState() {
        if isLoading {
            super.setTitle(nil, for: .normal)
            activityIndicator.startAnimating()
            isUserInteractionEnabled = false
        } else {
            super.setTitle(storedTitle, for: .normal)
            activityIndicator.stopAnimating()
            isUserInteractionEnabled = isEnabled
        }
    }
}
