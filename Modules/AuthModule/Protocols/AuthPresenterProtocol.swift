
protocol AuthPresenterInput {
    func didLoad()
    func didTapLogin(email: String, password: String)
}

protocol AuthPresenterOutput: AnyObject {
    func didLoginSuccessfully(userId: String)
    func didFailWith(error: Error)
}
