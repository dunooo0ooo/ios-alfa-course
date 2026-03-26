import UIKit

class AuthViewController: UIViewController, AuthView {
    var presenter: AuthPresenterInput?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.didLoad()
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            return
        }
        presenter?.didTapLogin(email: email, password: password)
    }

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    func render(_ state: AuthViewState) {
            switch state {
            case .initial:
                emailTextField.text = ""
                passwordTextField.text = ""
                loginButton.isEnabled = true
                loginButton.alpha = 1.0

            case .loading:
                loginButton.isEnabled = false
                loginButton.alpha = 0.5

            case .content(let email):
                emailTextField.text = email
                loginButton.isEnabled = true
                loginButton.alpha = 1.0

            case .error(let message):
                emailTextField.text = ""
                passwordTextField.text = ""
                loginButton.isEnabled = true
                loginButton.alpha = 1.0
            }
        }
}
