import Foundation

struct AuthenticationController {
    let httpClient: HTTPClient
    
    func registerUser(name: String, email: String, password: String) async throws -> RegistrationFormResponse {
        print("🔄 Intentando registrar usuario: \(email)")
        let response = try await httpClient.UserRegistration(name: name, email: email, password: password)
        
        // Verificar si el registro fue exitoso
        if !response.isSuccessful {
            throw NSError(domain: "", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Error al crear la cuenta. Por favor, intenta nuevamente."])
        }
        
        print("✅ Usuario registrado exitosamente")
        // No guardar tokens aquí - solo registrar, no hacer login automático
        return response
    }
    
    func loginUser(email: String, password: String) async throws -> Bool {
        print("🔄 Intentando login: \(email)")
        let loginResponse = try await httpClient.UserLogin(email: email, password: password)
        
        TokenStorage.set(identifier: "accessToken", value: loginResponse.accessToken)
        TokenStorage.set(identifier: "refreshToken", value: loginResponse.refreshToken)
        
        print("✅ Login exitoso")
        return loginResponse.accessToken != nil
    }
    
    func loginWithApple(appleUserId: String, email: String, name: String, identityToken: String) async throws -> Bool {
        print("🔄 Intentando login con Apple: \(email)")
        
        let appleLoginRequest = AppleLoginRequest(
            appleUserId: appleUserId,
            email: email,
            name: name,
            identityToken: identityToken
        )
        
        let loginResponse = try await httpClient.appleLogin(request: appleLoginRequest)
        
        TokenStorage.set(identifier: "accessToken", value: loginResponse.accessToken)
        TokenStorage.set(identifier: "refreshToken", value: loginResponse.refreshToken)
        
        print("✅ Login con Apple exitoso")
        return loginResponse.accessToken != nil
    }
}

struct AppleLoginRequest: Codable {
    let appleUserId: String
    let email: String
    let name: String
    let identityToken: String
    
    enum CodingKeys: String, CodingKey {
        case appleUserId = "apple_user_id"
        case email, name
        case identityToken = "identity_token"
    }
}
