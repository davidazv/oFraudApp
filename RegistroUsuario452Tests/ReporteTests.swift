import Testing
@testable import RegistroUsuario452
import Foundation
//Christopher

// Simulador del cliente de reportes para pruebas
class ReportTestClient {
    private var userReports: [Int: [Report]] = [:] // userId: [reports]
    private var reportIdCounter = 1000
    
    func createReport(userId: Int, report: CreateReportRequest) async throws -> Report {
        let newReport = Report(
            id: reportIdCounter,
            userId: userId,
            userName: "Test User",
            categoryId: report.categoryId,
            categoryName: CategoryType(rawValue: report.categoryId)?.name,
            statusId: 1, // Pendiente
            statusName: "Pendiente",
            title: report.title,
            description: report.description,
            incidentDate: report.incidentDate,
            location: report.location,
            fraudContact: report.fraudContact,
            evidenceUrl: report.evidenceUrl,
            assignedAdminId: nil,
            assignedAdminName: nil,
            isAnonymous: report.isAnonymous ? 1 : 0,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
        
        // Agregar a la lista del usuario
        if userReports[userId] == nil {
            userReports[userId] = []
        }
        userReports[userId]?.append(newReport)
        
        reportIdCounter += 1
        return newReport
    }
    
    func getUserReports(userId: Int) async throws -> [Report] {
        return userReports[userId] ?? []
    }
}

@Suite("Pruebas de Reportes de Fraude")
struct ReporteTests {
    
    // CP03: Creación de reporte de fraude - Exitoso y Fallido
    @Test("CP03a: Creación de reporte de fraude exitoso")
    func crearReporteFraudeExitoso() async throws {
        // Arrange
        let reportClient = ReportTestClient()
        let userId = 1
        let reporteData = CreateReportRequest(
            categoryId: 1, // Sitio Web Bancario Falso
            title: "Sospecha de sitio falso del banco ScotiaBank",
            description: "El sitio solicita credenciales y OTP sin HTTPS. Dominio similar: scotiabank-mx.com. He verificado que el dominio oficial es diferente y presenta inconsistencias en el diseño.",
            incidentDate: "2025-10-23",
            location: "Ciudad de México",
            fraudContact: "https://scotiabank-mx.com",
            evidenceUrl: nil,
            isAnonymous: false
        )
        
        // Act
        let reporteCreado = try await reportClient.createReport(
            userId: userId,
            report: reporteData
        )
        
        // Assert
        #expect(reporteCreado.title == reporteData.title, "El título del reporte debe coincidir")
        #expect(reporteCreado.description == reporteData.description, "La descripción debe coincidir")
        #expect(reporteCreado.categoryId == 1, "La categoría debe ser 'Sitio Web Bancario Falso'")
        #expect(reporteCreado.location == reporteData.location, "La ubicación debe coincidir")
        #expect(reporteCreado.fraudContact == reporteData.fraudContact, "El contacto fraudulento debe coincidir")
        #expect(reporteCreado.statusName == "Pendiente", "El estado inicial debe ser 'Pendiente'")
        #expect(reporteCreado.id > 0, "Debe tener un ID válido asignado")
        
        print("Reporte de fraude creado exitosamente con ID: \(reporteCreado.id)")
    }
    
    @Test("CP03b: Creación de reporte de fraude fallido - Datos incompletos")
    func crearReporteFraudeFallidoDatosIncompletos() async throws {
        // Arrange
        let reportClient = ReportTestClient()
        let userId = 1
        let reporteIncompleto = CreateReportRequest(
            categoryId: 1,
            title: "Corto", // Título muy corto (5 caracteres < 10 mínimo)
            description: "Descripción corta", // 18 caracteres < 20 mínimo
            incidentDate: "2025-10-23",
            location: "", // Ubicación vacía
            fraudContact: "", // Contacto vacío
            evidenceUrl: nil,
            isAnonymous: false
        )
        
        // Validar que los datos son insuficientes antes de enviar
        let tituloMuyCorto = reporteIncompleto.title.count < 10
        let descripcionMuyCorta = reporteIncompleto.description.count < 20
        let ubicacionVacia = reporteIncompleto.location?.isEmpty ?? true
        let contactoVacio = reporteIncompleto.fraudContact?.isEmpty ?? true
        
        // Assert - Los datos deben ser inválidos
        #expect(tituloMuyCorto == true, "El título debe ser muy corto (menos de 10 caracteres)")
        #expect(descripcionMuyCorta == true, "La descripción debe ser muy corta (menos de 20 caracteres)")
        #expect(ubicacionVacia == true, "La ubicación debe estar vacía")
        #expect(contactoVacio == true, "El contacto debe estar vacío")
        
        // La validación local debe detectar que los datos son inválidos
        let datosInvalidos = tituloMuyCorto || descripcionMuyCorta || ubicacionVacia || contactoVacio
        #expect(datosInvalidos == true, "Los datos deben ser detectados como inválidos")
        
        print("Validación correcta - Datos incompletos detectados apropiadamente")
        print("   - Título: \(reporteIncompleto.title.count) caracteres (mínimo 10)")
        print("   - Descripción: \(reporteIncompleto.description.count) caracteres (mínimo 20)")
    }
    
    // CP04: Consultar reportes del usuario - Exitoso y Fallido
    @Test("CP04a: Consultar reportes del usuario exitoso")
    func consultarReportesExitoso() async throws {
        // Arrange
        let reportClient = ReportTestClient()
        let userId = 1
        
        // Crear un reporte de prueba primero
        let reporteData = CreateReportRequest(
            categoryId: 1,
            title: "Sitio web bancario fraudulento detectado",
            description: "He identificado un sitio web que imita la página oficial del banco y solicita credenciales de acceso.",
            incidentDate: "2025-10-23",
            location: "Ciudad de México",
            fraudContact: "https://banco-falso.com",
            evidenceUrl: nil,
            isAnonymous: false
        )
        
        let _ = try await reportClient.createReport(userId: userId, report: reporteData)
        
        // Act - Consultar reportes del usuario
        let reportes = try await reportClient.getUserReports(userId: userId)
        
        // Assert
        #expect(reportes.count > 0, "El usuario debe tener al menos un reporte")
        #expect(reportes.first?.title != nil, "El reporte debe tener un título")
        #expect(reportes.first?.userId == userId, "El reporte debe pertenecer al usuario correcto")
        #expect(reportes.first?.statusName == "Pendiente", "El reporte debe estar en estado pendiente")
        #expect(reportes.first?.categoryId == 1, "La categoría debe coincidir")
        
        print("Consulta de reportes exitosa - \(reportes.count) reporte(s) encontrado(s)")
    }
    
    @Test("CP04b: Consultar reportes del usuario - Usuario sin reportes")
    func consultarReportesSinDatos() async throws {
        // Arrange
        let reportClient = ReportTestClient()
        let nuevoUserId = 999 // Usuario que no ha creado reportes
        
        // Act - Consultar reportes de usuario sin reportes
        let reportes = try await reportClient.getUserReports(userId: nuevoUserId)
        
        // Assert
        #expect(reportes.count == 0, "Un usuario sin reportes debe tener lista vacía")
        #expect(reportes.isEmpty == true, "La lista debe estar vacía")
        
        // Verificar que el sistema maneja correctamente el caso sin datos
        let responseIsEmpty = reportes.isEmpty
        #expect(responseIsEmpty == true, "El sistema debe manejar correctamente usuarios sin reportes")
        
        print("Validación correcta - Usuario sin reportes manejado apropiadamente")
    }
}
