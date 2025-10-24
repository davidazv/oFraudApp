import Testing
@testable import RegistroUsuario452
import Foundation
//Emiliano

// Simulador del cliente de autenticación para pruebas
class AuthenticationTestClient {
    private var registeredUsers: [String] = []
    private var authenticatedUsers: [String: String] = [:] // email: password
    
    func registerUser(name: String, email: String, password: String) async throws -> RegistrationFormResponse {
        // Validar que el email no esté duplicado
        guard !registeredUsers.contains(email) else {
            throw NSError(domain: "AuthError", code: 400, 
                         userInfo: [NSLocalizedDescriptionKey: "El correo ya está registrado"])
        }
        
        // Registrar usuario
        registeredUsers.append(email)
        authenticatedUsers[email] = password
        
        return RegistrationFormResponse(
            id: Int.random(in: 1000...9999),
            email: email,
            name: name,
            passwordHash: "hashed_\(password)",
            salt: "salt_123"
        )
    }
    
    func loginUser(email: String, password: String) async throws -> LoginResponse {
        // Verificar que el usuario existe
        guard let storedPassword = authenticatedUsers[email] else {
            throw NSError(domain: "AuthError", code: 401, 
                         userInfo: [NSLocalizedDescriptionKey: "Usuario no encontrado"])
        }
        
        // Verificar contraseña
        guard storedPassword == password else {
            throw NSError(domain: "AuthError", code: 401, 
                         userInfo: [NSLocalizedDescriptionKey: "Contraseña incorrecta"])
        }
        
        return LoginResponse(
            accessToken: "access_token_\(UUID().uuidString)",
            refreshToken: "refresh_token_\(UUID().uuidString)"
        )
    }
}

// Estructura para simular respuesta de login
struct LoginResponse {
    let accessToken: String
    let refreshToken: String
}

@Suite("Pruebas de Autenticación")
struct AuthenticationTests {
    
    // CP01: Registro de usuario - Exitoso y Fallido
    @Test("CP01a: Registro de usuario exitoso")
    func registroUsuarioExitoso() async throws {
        // Arrange
        let authClient = AuthenticationTestClient()
        let testName = "Emiliano Test"
        let testEmail = "emiliano.test\(UUID().uuidString)@example.com" // Email único
        let testPassword = "Test1234"
        
        // Act
        let resultado = try await authClient.registerUser(
            name: testName,
            email: testEmail,
            password: testPassword
        )
        
        // Assert
        #expect(resultado.isSuccessful == true, "El registro debe ser exitoso")
        #expect(resultado.email == testEmail, "El email debe coincidir")
        #expect(resultado.name == testName, "El nombre debe coincidir")
        #expect(resultado.id != nil, "Debe tener un ID asignado")
        #expect(resultado.id! > 0, "El ID debe ser válido")
        
        print("Usuario registrado exitosamente con ID: \(resultado.id!)")
    }
    
    @Test("CP01b: Registro de usuario fallido - Email duplicado")
    func registroUsuarioFallidoEmailDuplicado() async throws {
        // Arrange
        let authClient = AuthenticationTestClient()
        let emailExistente = "usuario.duplicado\(UUID().uuidString)@example.com"
        let testName = "Usuario Duplicado"
        let testPassword = "Test1234"
        
        // Primero registramos el usuario
        let _ = try await authClient.registerUser(
            name: testName,
            email: emailExistente,
            password: testPassword
        )
        
        // Act & Assert - Intentar registrar el mismo email nuevamente
        var errorCapturado: Error?
        
        do {
            let _ = try await authClient.registerUser(
                name: testName,
                email: emailExistente,
                password: testPassword
            )
            #expect(Bool(false), "El registro debería haber fallado con email duplicado")
        } catch {
            errorCapturado = error
        }
        
        // Verificar que se capturó el error esperado
        #expect(errorCapturado != nil, "Debe existir un error")
        
        let errorMessage = errorCapturado?.localizedDescription ?? ""
        #expect(errorMessage.contains("ya está registrado") || 
                errorMessage.contains("duplicado") || 
                errorMessage.contains("existe"),
                "El error debe indicar que el correo ya existe: \(errorMessage)")
        
        print("Validación correcta - Error capturado: \(errorMessage)")
    }
    
    // CP02: Inicio de sesión - Exitoso y Fallido
    @Test("CP02a: Inicio de sesión exitoso")
    func inicioSesionExitoso() async throws {
        // Arrange
        let authClient = AuthenticationTestClient()
        let testEmail = "emiliano@example.com"
        let testPassword = "ValidPassword123"
        
        // Primero registramos al usuario
        let _ = try await authClient.registerUser(
            name: "Emiliano Test",
            email: testEmail,
            password: testPassword
        )
        
        // Act - Intentar login con credenciales correctas
        let loginResult = try await authClient.loginUser(
            email: testEmail,
            password: testPassword
        )
        
        // Assert
        #expect(!loginResult.accessToken.isEmpty, "Debe recibir token de acceso")
        #expect(!loginResult.refreshToken.isEmpty, "Debe recibir token de refresh")
        #expect(loginResult.accessToken.contains("access_token_"), "Token debe tener formato correcto")
        
        print("Login exitoso con tokens generados")
    }
    
    @Test("CP02b: Inicio de sesión fallido - Contraseña incorrecta")
    func inicioSesionFallidoPasswordIncorrecta() async throws {
        // Arrange
        let authClient = AuthenticationTestClient()
        let testEmail = "emiliano@example.com"
        let correctPassword = "ValidPassword123"
        let wrongPassword = "WrongPassword"
        
        // Registrar usuario con contraseña correcta
        let _ = try await authClient.registerUser(
            name: "Emiliano Test",
            email: testEmail,
            password: correctPassword
        )
        
        // Act & Assert - Intentar login con contraseña incorrecta
        var errorCapturado: Error?
        
        do {
            let _ = try await authClient.loginUser(
                email: testEmail,
                password: wrongPassword
            )
            #expect(Bool(false), "El login debería haber fallado con contraseña incorrecta")
        } catch {
            errorCapturado = error
        }
        
        // Verificar que se capturó el error esperado
        #expect(errorCapturado != nil, "Debe existir un error")
        
        let errorMessage = errorCapturado?.localizedDescription ?? ""
        #expect(errorMessage.contains("incorrecta") || 
                errorMessage.contains("inválida") || 
                errorMessage.contains("Contraseña"),
                "El error debe indicar contraseña incorrecta: \(errorMessage)")
        
        print("Validación correcta - Error capturado: \(errorMessage)")
    }
}

// Tags para organizar las pruebas
extension Tag {
    @Tag static var registration: Self
    @Tag static var success: Self
    @Tag static var failure: Self
    @Tag static var reportes: Self
    @Tag static var soporte: Self
    @Tag static var perfil: Self
}
