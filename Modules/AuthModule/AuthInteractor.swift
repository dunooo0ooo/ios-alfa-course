import Foundation
class AuthInteractor: AuthInteractorInput {
    var presenter: AuthInteractorOutput?
    var service: AuthServiceProtocol?

    func didLoad() {
        presenter?.presentInitialState()
    }

    func login(email: String, password: String) {
        Task {
            do {
                await MainActor.run {
                    self.presenter?.presentLoadingState()
                }
                try Self.validate(email: email, password: password)
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

    private static func validate(email: String, password: String) throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "AuthValidation", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Введите email и пароль."
            ])
        }

        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard predicate.evaluate(with: email) else {
            throw NSError(domain: "AuthValidation", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "Некорректный формат email."
            ])
        }
    }
}
