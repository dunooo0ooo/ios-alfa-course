
protocol AuthInteractorInput {
    func login(email: String, password: String)
}

protocol AuthInteractorOutput: AnyObject {
    func loginDidSucceed(userId: String)
    func loginDidFail(with error: Error)
}
