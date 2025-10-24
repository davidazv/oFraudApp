import Testing
@testable import RegistroUsuario452
import Foundation
//David

// Estructuras para soporte técnico
struct SupportRequest {
    let title: String
    let description: String
    let priority: String
}

struct SupportResponse {
    let id: Int
    let title: String
    let description: String
    let priority: String
    let status: String
    let createdAt: String
}

// Simulador del cliente de soporte técnico
class SoporteTecnicoClient {
    private var requestIdCounter = 3000
    
    func enviarSolicitudSoporte(token: String, request: SupportRequest) async throws -> SupportResponse {
        // Validaciones de negocio
        guard !request.title.isEmpty else {
            throw NSError(domain: "SoporteError", code: 400, 
                         userInfo: [NSLocalizedDescriptionKey: "El título es requerido"])
        }
        
        guard request.title.count >= 10 else {
            throw NSError(domain: "SoporteError", code: 400, 
                         userInfo: [NSLocalizedDescriptionKey: "El título debe tener al menos 10 caracteres"])
        }
        
        guard !request.description.isEmpty else {
            throw NSError(domain: "SoporteError", code: 400, 
                         userInfo: [NSLocalizedDescriptionKey: "La descripción es requerida"])
        }
        
        guard request.description.count >= 20 else {
            throw NSError(domain: "SoporteError", code: 400, 
                         userInfo: [NSLocalizedDescriptionKey: "La descripción debe tener al menos 20 caracteres para proporcionar suficiente detalle"])
        }
        
        // Si pasa todas las validaciones, crear respuesta exitosa
        let requestId = requestIdCounter
        requestIdCounter += 1
        
        return SupportResponse(
            id: requestId,
            title: request.title,
            description: request.description,
            priority: request.priority,
            status: "pending",
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }
}

// Estructura para simular las notificaciones
struct NotificationRequest {
    let userId: Int
    let reportId: Int?
    let title: String
    let message: String
    let type: String
}

struct NotificationResponse {
    let notificationId: Int
    let sent: Bool
    let sentAt: String
}

// Simulador del cliente de notificaciones
class NotificationTestClient {
    private var validUserIds: Set<Int> = [1, 2, 3, 4, 5] // Usuarios válidos simulados
    private var notificationIdCounter = 2000
    
    func sendNotification(request: NotificationRequest) async throws -> NotificationResponse {
        // Validar que el usuario existe
        guard validUserIds.contains(request.userId) else {
            throw NSError(domain: "NotificationError", code: 404, 
                         userInfo: [NSLocalizedDescriptionKey: "Usuario no encontrado"])
        }
        
        // Validar campos requeridos
        guard !request.title.isEmpty else {
            throw NSError(domain: "NotificationError", code: 400, 
                         userInfo: [NSLocalizedDescriptionKey: "El título es requerido"])
        }
        
        guard !request.message.isEmpty else {
            throw NSError(domain: "NotificationError", code: 400, 
                         userInfo: [NSLocalizedDescriptionKey: "El mensaje es requerido"])
        }
        
        // Si pasa todas las validaciones, crear respuesta exitosa
        let notificationId = notificationIdCounter
        notificationIdCounter += 1
        
        return NotificationResponse(
            notificationId: notificationId,
            sent: true,
            sentAt: ISO8601DateFormatter().string(from: Date())
        )
    }
}

@Suite("Pruebas de Soporte Técnico")
struct SoporteTests {
    
    // CP05: Solicitud de soporte técnico - Exitoso y Fallido
    @Test("CP05a: Solicitud de soporte técnico exitosa")
    func solicitudSoporteTecnicoExitosa() async throws {
        // Arrange
        let soporteClient = SoporteTecnicoClient()
        let testToken = "valid-token-123"
        let solicitud = SupportRequest(
            title: "Problema al iniciar sesión después de actualizar contraseña",
            description: "No puedo acceder a mi cuenta después de actualizar la contraseña desde la configuración. He intentado recuperar la contraseña pero no recibo el correo de recuperación en mi bandeja de entrada.",
            priority: "urgent"
        )
        
        // Act
        let resultado = try await soporteClient.enviarSolicitudSoporte(
            token: testToken,
            request: solicitud
        )
        
        // Assert
        #expect(resultado.title == solicitud.title, "El título de la solicitud debe coincidir")
        #expect(resultado.description == solicitud.description, "La descripción debe coincidir")
        #expect(resultado.priority == "urgent", "La prioridad debe ser 'urgent'")
        #expect(resultado.status == "pending", "El estado inicial debe ser 'pending'")
        #expect(resultado.id > 0, "Debe tener un ID válido asignado")
        #expect(!resultado.createdAt.isEmpty, "Debe tener una fecha de creación")
        
        print("Solicitud de soporte creada exitosamente con ID: \(resultado.id)")
    }
    
    @Test("CP05b: Solicitud de soporte técnico fallida - Descripción inválida")
    func solicitudSoporteTecnicoFallidaDescripcionInvalida() async throws {
        // Arrange
        let soporteClient = SoporteTecnicoClient()
        let testToken = "valid-token-123"
        let solicitudInvalida = SupportRequest(
            title: "Error", // Título muy corto (5 caracteres < 10 mínimo)
            description: "Bug", // Descripción muy corta (3 caracteres < 20 mínimo)
            priority: "normal"
        )
        
        // Act & Assert
        var errorCapturado: Error?
        
        do {
            let _ = try await soporteClient.enviarSolicitudSoporte(
                token: testToken,
                request: solicitudInvalida
            )
            #expect(Bool(false), "La solicitud debería haber fallado con datos inválidos")
        } catch {
            errorCapturado = error
        }
        
        // Verificar que se capturó el error esperado
        #expect(errorCapturado != nil, "Debe existir un error")
        
        let errorMessage = errorCapturado?.localizedDescription ?? ""
        #expect(errorMessage.contains("descripción") || 
                errorMessage.contains("caracteres") || 
                errorMessage.contains("título") ||
                errorMessage.contains("detalle"),
                "El error debe mencionar el problema con la descripción o título: \(errorMessage)")
        
        print("Validación correcta - Error capturado: \(errorMessage)")
    }
    
    // CP06: Notificaciones de actualización de reportes - Exitoso y Fallido
    @Test("CP06a: Notificación enviada exitosamente")
    func notificacionEnviadaExitosa() async throws {
        // Arrange
        let notificationClient = NotificationTestClient()
        let notificacion = NotificationRequest(
            userId: 1, // Usuario válido
            reportId: 5,
            title: "Actualización de reporte",
            message: "Tu reporte de fraude ha sido revisado y aceptado por nuestro equipo. Gracias por contribuir a la seguridad de todos.",
            type: "success"
        )
        
        // Act
        let resultado = try await notificationClient.sendNotification(
            request: notificacion
        )
        
        // Assert
        #expect(resultado.sent == true, "La notificación debe enviarse exitosamente")
        #expect(resultado.notificationId > 0, "Debe tener un ID de notificación válido")
        #expect(!resultado.sentAt.isEmpty, "Debe tener timestamp de envío")
        #expect(resultado.notificationId >= 2000, "El ID debe estar en el rango esperado")
        
        print("Notificación enviada exitosamente con ID: \(resultado.notificationId)")
    }
    
    @Test("CP06b: Notificación fallida - Usuario inválido")
    func notificacionFallidaUsuarioInvalido() async throws {
        // Arrange
        let notificationClient = NotificationTestClient()
        let notificacionInvalida = NotificationRequest(
            userId: 99999, // Usuario que no existe
            reportId: 5,
            title: "Actualización de reporte",
            message: "Mensaje de prueba para usuario inexistente",
            type: "info"
        )
        
        // Act & Assert
        var errorCapturado: Error?
        
        do {
            let _ = try await notificationClient.sendNotification(
                request: notificacionInvalida
            )
            #expect(Bool(false), "La notificación debería haber fallado con usuario inválido")
        } catch {
            errorCapturado = error
        }
        
        // Verificar que se capturó el error esperado
        #expect(errorCapturado != nil, "Debe existir un error")
        
        let errorMessage = errorCapturado?.localizedDescription ?? ""
        #expect(errorMessage.contains("Usuario") || 
                errorMessage.contains("encontrado") || 
                errorMessage.contains("no existe"),
                "El error debe indicar que el usuario no existe: \(errorMessage)")
        
        print("Validación correcta - Error capturado: \(errorMessage)")
    }
}
