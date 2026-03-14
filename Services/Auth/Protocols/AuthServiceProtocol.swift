protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> UserSession
}
