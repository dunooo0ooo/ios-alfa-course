import Foundation

class AuthPresenter: AuthPresenterInput, AuthInteractorOutput {
    weak var view: AuthView?
    var router: AuthRouterInput?
    var interactor: AuthInteractorInput?

    func didLoad() {
        view?.render(.initial)
    }

    func didTapLogin(email: String, password: String) {
        view?.render(.loading)
        interactor?.login(email: email, password: password)
    }

    
    func loginDidSucceed(userId: String) {
        view?.render(.content(email: ""))
        router?.openCatalogModule(with: userId)
    }

    func loginDidFail(with error: Error) {
        view?.render(.error(message: error.localizedDescription))
    }
}
