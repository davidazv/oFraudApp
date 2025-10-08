import Foundation

struct RegistrationFormRequest: Codable {
    var name: String
    var email: String
    var password: String
}

// Respuesta de error del servidor
struct ErrorResponse: Decodable {
    let message: [String]?  // Puede ser un array
    let error: String?
    let statusCode: Int?
    
    var errorMessage: String {
        if let messages = message {
            return messages.joined(separator: "\n")
        }
        return error ?? "Error desconocido"
    }
}

// Respuesta flexible que puede manejar diferentes estructuras
struct RegistrationFormResponse: Decodable {
    let id: Int?
    let email: String?
    let name: String?
    let passwordHash: String?
    let salt: String?

    enum CodingKeys: String, CodingKey {
        case id, email, name
        case passwordHash = "password_hash"
        case salt
    }
    
    // Verificar si el registro fue exitoso
    var isSuccessful: Bool {
        return id != nil || email != nil
    }
}
