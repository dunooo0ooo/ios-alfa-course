import Foundation

class AuthPresenter: AuthInteractorOutput {
    weak var view: AuthView?
    var router: AuthRouterInput?

    func presentInitialState() {
        view?.render(.initial)
    }

    func presentLoadingState() {
        view?.render(.loading)
    }
    
    func loginDidSucceed(userId: String) {
        view?.render(.content(email: ""))
        router?.openCatalogModule(with: userId)
    }

    func loginDidFail(with error: Error) {
        view?.render(.error(message: error.localizedDescription))
    }
}
