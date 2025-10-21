//
//  ReportDTO.swift
//  RegistroUsuario452
//

import Foundation

struct Report: Codable, Identifiable {
    let id: Int
    let userId: Int?
    let userName: String?
    let categoryId: Int
    let categoryName: String?
    let statusId: Int
    let statusName: String?
    let title: String
    let description: String
    let incidentDate: String
    let location: String?
    let fraudContact: String?
    let evidenceUrl: String?
    let assignedAdminId: Int?
    let assignedAdminName: String?
    let isAnonymous: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case userName = "user_name"
        case categoryId = "category_id"
        case categoryName = "category_name"
        case statusId = "status_id"
        case statusName = "status_name"
        case title, description
        case incidentDate = "incident_date"
        case location
        case fraudContact = "fraud_contact"
        case evidenceUrl = "evidence_url"
        case assignedAdminId = "assigned_admin_id"
        case assignedAdminName = "assigned_admin_name"
        case isAnonymous = "is_anonymous"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var displayCategoryName: String {
        return categoryName ?? CategoryType.allCases.first(where: { $0.id == categoryId })?.name ?? "Desconocido"
    }
    
    var displayStatusName: String {
        return statusName ?? {
            switch statusId {
            case 1: return "Pendiente"
            case 2: return "Aceptado"
            case 3: return "Rechazado"
            default: return "Desconocido"
            }
        }()
    }
    
    var displayUserName: String {
        if isAnonymous == 1 {
            return "Usuario Anónimo"
        }
        return userName ?? "Usuario #\(userId ?? 0)"
    }
    
    var statusColor: String {
        switch statusId {
        case 1: return "yellow"
        case 2: return "green"
        case 3: return "red"
        default: return "gray"
        }
    }
    
    var formattedCreatedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let date = dateFormatter.date(from: createdAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd/MM/yyyy"
            return displayFormatter.string(from: date)
        }
        return createdAt
    }
    
    var formattedIncidentDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let date = dateFormatter.date(from: incidentDate) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd/MM/yyyy"
            return displayFormatter.string(from: date)
        }
        return incidentDate
    }
}

struct CreateReportRequest: Codable {
    let categoryId: Int
    let title: String
    let description: String
    let incidentDate: String
    let location: String?
    let fraudContact: String?
    let evidenceUrl: String?
    let isAnonymous: Bool
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case title, description
        case incidentDate = "incident_date"
        case location
        case fraudContact = "fraud_contact"
        case evidenceUrl = "evidence_url"
        case isAnonymous = "is_anonymous"
    }
}

enum CategoryType: Int, CaseIterable, Identifiable {
    case sitioWebBancario = 1
    case aplicacionBancaria = 2
    case phishingEmail = 3
    case estafaTelefonica = 4
    case smsFraudulento = 5
    case fraudeRedesSociales = 6
    case sitioComprasFalso = 7
    case estafaInversion = 8
    case fraudePresencial = 9
    case clonacionTarjetas = 10
    
    var id: Int { rawValue }
    
    var name: String {
        switch self {
        case .sitioWebBancario: return "Sitio Web Bancario Falso"
        case .aplicacionBancaria: return "Aplicación Bancaria Falsa"
        case .phishingEmail: return "Phishing por Email"
        case .estafaTelefonica: return "Estafa Telefónica"
        case .smsFraudulento: return "SMS Fraudulento"
        case .fraudeRedesSociales: return "Fraude en Redes Sociales"
        case .sitioComprasFalso: return "Sitio de Compras Falso"
        case .estafaInversion: return "Estafa de Inversión"
        case .fraudePresencial: return "Fraude Presencial"
        case .clonacionTarjetas: return "Clonación de Tarjetas"
        }
    }
    
    var contactPlaceholder: String {
        switch self {
        case .sitioWebBancario, .sitioComprasFalso:
            return "URL del sitio (ej: www.ejemplo.com)"
        case .aplicacionBancaria:
            return "Nombre de la app"
        case .phishingEmail:
            return "Correo remitente"
        case .estafaTelefonica, .smsFraudulento:
            return "Número telefónico"
        case .fraudeRedesSociales:
            return "Perfil o cuenta"
        default:
            return "Información de contacto"
        }
    }
}
