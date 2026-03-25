
protocol AuthPresenterInput {
}

protocol AuthPresenterOutput: AnyObject {
    func didLoginSuccessfully(userId: String)
    func didFailWith(error: Error)
}
