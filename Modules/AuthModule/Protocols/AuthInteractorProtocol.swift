
protocol AuthInteractorInput {
    func didLoad()
    func login(email: String, password: String)
}

protocol AuthInteractorOutput: AnyObject {
    func presentInitialState()
    func presentLoadingState()
    func loginDidSucceed(userId: String)
    func loginDidFail(with error: Error)
}
