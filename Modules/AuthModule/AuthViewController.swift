import UIKit

final class AuthViewController: UIViewController, AuthView, UITextFieldDelegate {
    var interactor: AuthInteractorInput?

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.apply(.heroTitle)
        label.numberOfLines = 0
        label.text = "Музыка без лишнего шума"
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.apply(.body)
        label.numberOfLines = 0
        label.text = "Войдите, чтобы открыть подборку треков и перейти к списку релизов."
        return label
    }()

    private lazy var emailField: DSTextField = {
        let field = DSTextField(configuration: .init(title: "Email", placeholder: "user@example.com"))
        field.textField.keyboardType = .emailAddress
        field.textField.textContentType = .username
        field.textField.autocapitalizationType = .none
        field.textField.autocorrectionType = .no
        field.textField.returnKeyType = .next
        field.textField.delegate = self
        field.textField.accessibilityIdentifier = "emailTextField"
        return field
    }()

    private lazy var passwordField: DSTextField = {
        let field = DSTextField(configuration: .init(title: "Пароль", placeholder: "Введите пароль"))
        field.textField.isSecureTextEntry = true
        field.textField.textContentType = .password
        field.textField.returnKeyType = .go
        field.textField.delegate = self
        field.textField.accessibilityIdentifier = "passwordTextField"
        return field
    }()

    private lazy var loginButton: DSButton = {
        let button = DSButton(configuration: .init(title: "Войти", style: .primary))
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "loginButton"
        return button
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.apply(.error)
        label.numberOfLines = 0
        label.alpha = 0
        label.accessibilityIdentifier = "errorLabel"
        return label
    }()

    private lazy var formStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emailField, passwordField, errorLabel, loginButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = DS.Spacing.large
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        interactor?.didLoad()
    }

    private func setupUI() {
        view.backgroundColor = DS.Colors.background

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(formStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: DS.Spacing.xxLarge),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: DS.Spacing.screenInset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -DS.Spacing.screenInset),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DS.Spacing.medium),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            formStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: DS.Spacing.xxLarge),
            formStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            formStack.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            formStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -DS.Spacing.xxLarge),
        ])
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChangeFrame(_ note: Notification) {
        guard
            let userInfo = note.userInfo,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let keyboardInView = view.convert(endFrame, from: nil)
        let intersection = view.bounds.intersection(keyboardInView)
        let inset = intersection.height
        scrollView.contentInset.bottom = inset
        scrollView.verticalScrollIndicatorInsets.bottom = inset
        scrollView.horizontalScrollIndicatorInsets.bottom = inset

        if let activeField = findActiveTextField(),
           activeField.frame.maxY > keyboardInView.minY {
            scrollView.scrollRectToVisible(activeField.frame.insetBy(dx: 0, dy: -DS.Spacing.xLarge), animated: true)
        }
    }

    private func findActiveTextField() -> UITextField? {
        [emailField.textField, passwordField.textField].first { $0.isFirstResponder }
    }

    @objc private func loginTapped() {
        interactor?.login(email: emailField.text ?? "", password: passwordField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField.textField {
            passwordField.becomeActive()
        } else {
            loginTapped()
            passwordField.resignActive()
        }
        return true
    }

    func render(_ state: AuthViewState) {
        let viewModel: AuthScreenViewModel
        switch state {
        case .initial(let model), .loading(let model), .content(let model), .error(let model):
            viewModel = model
        }

        emailField.configure(viewModel.emailField)
        passwordField.configure(viewModel.passwordField)
        loginButton.configure(viewModel.loginButton)
        errorLabel.text = viewModel.errorMessage

        let targetAlpha: CGFloat = viewModel.errorMessage == nil ? 0 : 1
        UIView.animate(withDuration: 0.25) {
            self.errorLabel.alpha = targetAlpha
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
