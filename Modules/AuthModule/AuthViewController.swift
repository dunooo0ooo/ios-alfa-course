import UIKit

final class AuthViewController: UIViewController, AuthView, UITextFieldDelegate {
    
    var presenter: AuthPresenterInput?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let errorLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        presenter?.didLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        scrollView.contentMode = .scaleToFill
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        emailTextField.borderStyle = .roundedRect
        emailTextField.placeholder = "Email"
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.delegate = self
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emailTextField)
        
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.placeholder = "Пароль"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordTextField)
        
        errorLabel.textColor = .systemRed
        errorLabel.font = UIFont.systemFont(ofSize: 14)
        errorLabel.numberOfLines = 0
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.alpha = 0
        contentView.addSubview(errorLabel)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicator)
        
        loginButton.setTitle("Войти", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.layer.cornerRadius = 8
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
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
            activityIndicator.leadingAnchor.constraint(equalTo: loginButton.trailingAnchor, constant: 8),

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
        scrollView.scrollIndicatorInsets.bottom = inset
        if let activeField = findActiveTextField(),
           activeField.frame.maxY > keyboardInView.minY {
            scrollView.scrollRectToVisible(activeField.frame, animated: true)
        }
    }
    
    private func findActiveTextField() -> UITextField? {
        return [emailTextField, passwordTextField].first { $0.isFirstResponder }
    }
    
    @objc private func loginTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            return
        }
        presenter?.didTapLogin(email: email, password: password)
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
    
    func textFieldDidChange(_ textField: UITextField) {
        if textField == emailTextField {
            let isValid = isValidEmail(emailTextField.text ?? "")
            updateTextFieldBorder(emailTextField, isValid: isValid)
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return predicate.evaluate(with: email)
    }
    
    private func updateTextFieldBorder(_ textField: UITextField, isValid: Bool) {
        textField.layer.borderWidth = isValid ? 0 : 1
        textField.layer.borderColor = isValid ? nil : UIColor.systemRed.cgColor
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
            updateTextFieldBorder(emailTextField, isValid: true)
            updateTextFieldBorder(passwordTextField, isValid: true)
            
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
            updateTextFieldBorder(emailTextField, isValid: true)
            updateTextFieldBorder(passwordTextField, isValid: true)
            
        case .error(let message):
            errorLabel.text = message
            UIView.animate(withDuration: 0.3) {
                self.errorLabel.alpha = 1.0
            }
            loginButton.isEnabled = true
            loginButton.alpha = 1.0
            activityIndicator.stopAnimating()
            let isValidEmail = self.isValidEmail(self.emailTextField.text ?? "")
            let isValidPassword = ((self.passwordTextField.text) == nil)
            self.updateTextFieldBorder(self.emailTextField, isValid: isValidEmail)
            self.updateTextFieldBorder(self.passwordTextField, isValid: isValidPassword)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
