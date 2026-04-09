import UIKit

final class DSTextField: UIView {
    struct Configuration: Equatable {
        let title: String?
        let placeholder: String
        let text: String?
        let errorText: String?

        init(title: String?, placeholder: String, text: String? = nil, errorText: String? = nil) {
            self.title = title
            self.placeholder = placeholder
            self.text = text
            self.errorText = errorText
        }
    }

    let textField = UITextField()

    private let titleLabel = UILabel()
    private let containerView = UIView()
    private let errorLabel = UILabel()
    private var currentConfiguration = Configuration(title: nil, placeholder: "")

    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }

    init(configuration: Configuration) {
        self.currentConfiguration = configuration
        super.init(frame: .zero)
        setupUI()
        configure(configuration)
    }

    required init?(coder: NSCoder) { nil }

    func configure(_ configuration: Configuration) {
        currentConfiguration = configuration
        titleLabel.text = configuration.title
        titleLabel.isHidden = configuration.title == nil
        textField.placeholder = configuration.placeholder
        textField.text = configuration.text
        applyError(configuration.errorText)
    }

    func setError(_ message: String?) {
        currentConfiguration = Configuration(
            title: currentConfiguration.title,
            placeholder: currentConfiguration.placeholder,
            text: textField.text,
            errorText: message
        )
        applyError(message)
    }

    func becomeActive() {
        textField.becomeFirstResponder()
    }

    func resignActive() {
        textField.resignFirstResponder()
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.apply(.caption)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = DS.Colors.surfaceElevated
        containerView.layer.cornerRadius = DS.Spacing.cornerRadius
        containerView.layer.cornerCurve = .continuous
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = DS.Colors.border.cgColor

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = DS.Typography.body()
        textField.textColor = DS.Colors.textPrimary
        textField.tintColor = DS.Colors.primary
        textField.clearButtonMode = .whileEditing

        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.apply(.error)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        addSubview(titleLabel)
        addSubview(containerView)
        addSubview(errorLabel)
        containerView.addSubview(textField)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            containerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DS.Spacing.small),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: DS.Spacing.fieldHeight),

            textField.topAnchor.constraint(equalTo: containerView.topAnchor),
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: DS.Spacing.large),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -DS.Spacing.large),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            errorLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: DS.Spacing.small),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func applyError(_ message: String?) {
        errorLabel.text = message
        errorLabel.isHidden = message == nil
        containerView.layer.borderColor = (message == nil ? DS.Colors.border : DS.Colors.error).cgColor
    }
}
