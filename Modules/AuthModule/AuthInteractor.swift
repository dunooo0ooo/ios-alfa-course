
class AuthInteractor: AuthInteractorInput {
    var presenter: AuthInteractorOutput?
    var service: AuthServiceProtocol?

    func login(email: String, password: String) {
        Task {
            do {
                let response = try await service?.login(email: email, password: password)
                guard let userId = response?.userId else { return }
                await MainActor.run {
                    presenter?.loginDidSucceed(userId: userId)
                }
            } catch {
                await MainActor.run {
                    presenter?.loginDidFail(with: error)
                }
            }
        }
    }
}
