import UIKit

final class AuthViewController: UIViewController, AuthView, UITextFieldDelegate {
    
    var interactor: AuthInteractorInput?
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.contentMode = .scaleToFill
        view.alwaysBounceVertical = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Пароль"
        textField.isSecureTextEntry = true
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        interactor?.didLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(emailTextField)
        
        contentView.addSubview(passwordTextField)
        
        contentView.addSubview(errorLabel)
        
        contentView.addSubview(activityIndicator)
        
        contentView.addSubview(loginButton)
        
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
            
            emailTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            errorLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            // Кнопка занимает почти всю ширину, поэтому индикатор справа "уезжает" за экран.
            // Центрируем его относительно кнопки.
            activityIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),

            loginButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            loginButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        
        emailTextField.accessibilityIdentifier = "emailTextField"
        passwordTextField.accessibilityIdentifier = "passwordTextField"
        loginButton.accessibilityIdentifier = "loginButton"
        errorLabel.accessibilityIdentifier = "errorLabel"
        activityIndicator.accessibilityIdentifier = "activityIndicator"
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
            scrollView.scrollRectToVisible(activeField.frame, animated: true)
        }
    }
    
    private func findActiveTextField() -> UITextField? {
        return [emailTextField, passwordTextField].first { $0.isFirstResponder }
    }
    
    @objc private func loginTapped() {
        interactor?.login(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            loginTapped()
            textField.resignFirstResponder()
        }
        return true
    }
    
    func render(_ state: AuthViewState) {
        switch state {
        case .initial:
            emailTextField.text = ""
            passwordTextField.text = ""
            errorLabel.alpha = 0
            loginButton.isEnabled = true
            loginButton.alpha = 1.0
            activityIndicator.stopAnimating()
            
        case .loading:
            loginButton.isEnabled = false
            loginButton.alpha = 0.5
            activityIndicator.startAnimating()
            
        case .content(let email):
            emailTextField.text = email
            errorLabel.alpha = 0
            loginButton.isEnabled = true
            loginButton.alpha = 1.0
            activityIndicator.stopAnimating()
            
        case .error(let message):
            errorLabel.text = message
            UIView.animate(withDuration: 0.3) {
                self.errorLabel.alpha = 1.0
            }
            loginButton.isEnabled = true
            loginButton.alpha = 1.0
            activityIndicator.stopAnimating()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
