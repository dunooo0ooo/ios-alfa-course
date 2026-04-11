
protocol AuthInteractorInput {
    func didLoad()
    func login(email: String, password: String)
}

protocol AuthInteractorOutput: AnyObject {
    func presentInitialState()
    func presentLoadingState(email: String, password: String)
    func loginDidSucceed(userId: String, email: String)
    func loginDidFail(with error: Error, email: String, password: String)
}
