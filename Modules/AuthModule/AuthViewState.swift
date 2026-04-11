
struct AuthScreenViewModel: Equatable {
    let emailField: DSTextField.Configuration
    let passwordField: DSTextField.Configuration
    let loginButton: DSButton.Configuration
    let errorMessage: String?
}

enum AuthViewState: Equatable {
    case initial(AuthScreenViewModel)
    case loading(AuthScreenViewModel)
    case content(AuthScreenViewModel)
    case error(AuthScreenViewModel)
}
