import Testing
@testable import RegistroUsuario452
import Foundation
//Karen

// Estructura para simular las solicitudes de cambio de contraseña
struct CambioPasswordRequest {
    let currentPassword: String
    let newPassword: String
    let confirmPassword: String
}

// Simulador del cliente de perfil para cambio de contraseña
class PerfilPasswordClient {
    private var storedPassword: String = "CorrectPassword123"
    private var userProfile: Profile?
    
    func simularUsuarioAutenticado(userId: Int, currentPassword: String) {
        storedPassword = currentPassword
        userProfile = Profile(
            id: userId,
            email: "test@example.com",
            name: "Test User",
            passwordHash: "hashed_\(currentPassword)",
            salt: "test_salt"
        )
    }
    
    func cambiarPassword(token: String, request: CambioPasswordRequest) async throws -> Bool {
        // Validar que el usuario esté autenticado
        guard userProfile != nil else {
            throw NSError(domain: "AuthError", code: 401, 
                         userInfo: [NSLocalizedDescriptionKey: "Usuario no autenticado"])
        }
        
        // Validar contraseña actual
        guard request.currentPassword == storedPassword else {
            throw NSError(domain: "PasswordError", code: 400, 
                         userInfo: [NSLocalizedDescriptionKey: "La contraseña actual es incorrecta"])
        }
        
        // Validar que las nuevas contraseñas coincidan
        guard request.newPassword == request.confirmPassword else {
            throw NSError(domain: "PasswordError", code: 400, 
                         userInfo: [NSLocalizedDescriptionKey: "Las contraseñas nuevas no coinciden"])
        }
        
        // Validar longitud de nueva contraseña
        guard request.newPassword.count >= 8 else {
            throw NSError(domain: "PasswordError", code: 400, 
                         userInfo: [NSLocalizedDescriptionKey: "La nueva contraseña debe tener al menos 8 caracteres"])
        }
        
        // Si todas las validaciones pasan, cambiar la contraseña
        storedPassword = request.newPassword
        return true
    }
    
    func getCurrentPassword() -> String {
        return storedPassword
    }
    
    func isUserAuthenticated() -> Bool {
        return userProfile != nil
    }
}

// Estructura para simular respuesta de logout
struct LogoutResponse {
    let success: Bool
    let message: String
}

// Simulador del cliente de autenticación para logout
class AuthenticationLogoutClient {
    private var accessToken: String?
    private var refreshToken: String?
    private var userId: Int?
    private var isSessionActive: Bool = false
    
    func setActiveSession(accessToken: String, refreshToken: String, userId: Int) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.userId = userId
        self.isSessionActive = true
    }
    
    func logoutUser() async throws -> Bool {
        // Verificar si hay una sesión activa
        guard isSessionActive else {
            throw NSError(domain: "AuthError", code: 401, 
                         userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa para cerrar"])
        }
        
        // Invalidar tokens y limpiar sesión
        accessToken = nil
        refreshToken = nil
        userId = nil
        isSessionActive = false
        
        return true
    }
    
    func getAccessToken() -> String? {
        return accessToken
    }
    
    func getRefreshToken() -> String? {
        return refreshToken
    }
    
    func isUserSessionActive() -> Bool {
        return isSessionActive
    }
    
    func getUserId() -> Int? {
        return userId
    }
}

@Suite("Pruebas de Gestión de Perfil")
struct PerfilTests {
    
    // CP07: Cambio de contraseña - Exitoso y Fallido
    @Test("CP07a: Cambio de contraseña exitoso")
    func cambioContrasenaExitoso() async throws {
        // Arrange
        let perfilClient = PerfilPasswordClient()
        let testToken = "valid-token-123"
        
        // Simular que el usuario ya está autenticado
        perfilClient.simularUsuarioAutenticado(
            userId: 1, 
            currentPassword: "OldPassword123"
        )
        
        let cambioPassword = CambioPasswordRequest(
            currentPassword: "OldPassword123",
            newPassword: "NewPassword123",
            confirmPassword: "NewPassword123"
        )
        
        // Act
        let resultado = try await perfilClient.cambiarPassword(
            token: testToken,
            request: cambioPassword
        )
        
        // Assert
        #expect(resultado == true, "El cambio de contraseña debe ser exitoso")
        #expect(perfilClient.getCurrentPassword() == "NewPassword123", 
                "La contraseña debe haberse actualizado correctamente")
        #expect(perfilClient.isUserAuthenticated() == true, "El usuario debe seguir autenticado")
        
        print("Contraseña cambiada exitosamente de OldPassword123 a NewPassword123")
    }
    
    @Test("CP07b: Cambio de contraseña fallido - Contraseña actual incorrecta")
    func cambioContrasenaFallidoPasswordIncorrecta() async throws {
        // Arrange
        let perfilClient = PerfilPasswordClient()
        let testToken = "valid-token-123"
        
        // Simular que el usuario está autenticado con una contraseña específica
        perfilClient.simularUsuarioAutenticado(
            userId: 1, 
            currentPassword: "CorrectPassword123"
        )
        
        let cambioPasswordInvalido = CambioPasswordRequest(
            currentPassword: "WrongPassword", // Contraseña actual incorrecta
            newPassword: "NewPassword123",
            confirmPassword: "NewPassword123"
        )
        
        // Act & Assert
        var errorCapturado: Error?
        
        do {
            let _ = try await perfilClient.cambiarPassword(
                token: testToken,
                request: cambioPasswordInvalido
            )
            #expect(Bool(false), "El cambio debería haber fallado con contraseña incorrecta")
        } catch {
            errorCapturado = error
        }
        
        // Verificar que se capturó el error esperado
        #expect(errorCapturado != nil, "Debe existir un error")
        
        let errorMessage = errorCapturado?.localizedDescription ?? ""
        #expect(errorMessage.contains("incorrecta") || 
                errorMessage.contains("actual") || 
                errorMessage.contains("inválida"),
                "El error debe indicar que la contraseña actual es incorrecta: \(errorMessage)")
        
        // Verificar que la contraseña no cambió
        #expect(perfilClient.getCurrentPassword() == "CorrectPassword123",
                "La contraseña no debe haberse cambiado")
        
        print("Validación correcta - Error capturado: \(errorMessage)")
    }
    
    // CP08: Cerrar sesión - Exitoso y Fallido
    @Test("CP08a: Cerrar sesión exitoso")
    func cerrarSesionExitoso() async throws {
        // Arrange
        let authClient = AuthenticationLogoutClient()
        
        // Simular sesión activa
        authClient.setActiveSession(
            accessToken: "valid-access-token-xyz",
            refreshToken: "valid-refresh-token-abc",
            userId: 1
        )
        
        // Verificar que la sesión está activa antes del logout
        #expect(authClient.isUserSessionActive() == true, "La sesión debe estar activa inicialmente")
        #expect(authClient.getAccessToken() != nil, "Debe tener token de acceso")
        #expect(authClient.getRefreshToken() != nil, "Debe tener token de refresh")
        
        // Act
        let resultado = try await authClient.logoutUser()
        
        // Assert
        #expect(resultado == true, "El logout debe ser exitoso")
        #expect(authClient.getAccessToken() == nil, "El token de acceso debe ser eliminado")
        #expect(authClient.getRefreshToken() == nil, "El token de refresh debe ser eliminado")
        #expect(authClient.isUserSessionActive() == false, "La sesión debe estar inactiva")
        #expect(authClient.getUserId() == nil, "El ID de usuario debe ser eliminado")
        
        print("Sesión cerrada exitosamente - Todos los tokens invalidados")
    }
    
    @Test("CP08b: Cerrar sesión fallido - Sesión ya cerrada")
    func cerrarSesionFallidoSesionInactiva() async throws {
        // Arrange
        let authClient = AuthenticationLogoutClient()
        
        // No establecer sesión activa (simular usuario no logueado)
        #expect(authClient.isUserSessionActive() == false, "No debe haber sesión activa")
        #expect(authClient.getAccessToken() == nil, "No debe tener token de acceso")
        #expect(authClient.getRefreshToken() == nil, "No debe tener token de refresh")
        
        // Act & Assert
        var errorCapturado: Error?
        
        do {
            let _ = try await authClient.logoutUser()
            #expect(Bool(false), "El logout debería fallar sin sesión activa")
        } catch {
            errorCapturado = error
        }
        
        // Verificar que se capturó el error esperado
        #expect(errorCapturado != nil, "Debe existir un error")
        
        let errorMessage = errorCapturado?.localizedDescription ?? ""
        #expect(errorMessage.contains("No hay sesión") || 
                errorMessage.contains("activa") || 
                errorMessage.contains("cerrar"),
                "El error debe indicar que no hay sesión activa: \(errorMessage)")
        
        // Verificar que el estado se mantiene sin cambios
        #expect(authClient.isUserSessionActive() == false, "La sesión debe mantenerse inactiva")
        
        print("Validación correcta - Error capturado: \(errorMessage)")
    }
}
