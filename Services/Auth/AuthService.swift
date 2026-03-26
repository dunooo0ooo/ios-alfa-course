import Foundation

class AuthService: AuthServiceProtocol {
    func login(email: String, password: String) async throws -> UserSession {

        let validEmail = "user@example.com"
        let validPassword = "password123"
        
        guard email == validEmail, password == validPassword else {
            throw AuthError.invalidCredentials
        }
        
        return UserSession(token: "fake_token_123", userId: "user_123")
    }
    
}

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    
    var errorDescription: String? {
        return "Неверный логин или пароль"
    }
}
