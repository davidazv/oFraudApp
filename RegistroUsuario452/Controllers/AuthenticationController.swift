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
    
}

