import Foundation

class AuthPresenter: AuthInteractorOutput {
    weak var view: AuthView?
    var router: AuthRouterInput?

    func presentInitialState() {
        view?.render(.initial(makeViewModel(email: "", password: "", isLoading: false, errorMessage: nil)))
    }

    func presentLoadingState(email: String, password: String) {
        view?.render(.loading(makeViewModel(email: email, password: password, isLoading: true, errorMessage: nil)))
    }
    
    func loginDidSucceed(userId: String, email: String) {
        view?.render(.content(makeViewModel(email: email, password: "", isLoading: false, errorMessage: nil)))
        router?.openCatalogModule(with: userId)
    }

    func loginDidFail(with error: Error, email: String, password: String) {
        view?.render(.error(makeViewModel(
            email: email,
            password: password,
            isLoading: false,
            errorMessage: error.localizedDescription
        )))
    }

    private func makeViewModel(
        email: String,
        password: String,
        isLoading: Bool,
        errorMessage: String?
    ) -> AuthScreenViewModel {
        AuthScreenViewModel(
            emailField: .init(
                title: "Email",
                placeholder: "user@example.com",
                text: email,
                errorText: nil
            ),
            passwordField: .init(
                title: "Пароль",
                placeholder: "Введите пароль",
                text: password,
                errorText: nil
            ),
            loginButton: .init(
                title: "Войти",
                style: .primary,
                isEnabled: !isLoading,
                isLoading: isLoading
            ),
            errorMessage: errorMessage
        )
    }
}
