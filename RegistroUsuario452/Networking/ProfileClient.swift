//
//  ProfileClient.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 12/09/25.
//

import Foundation

class ProfileClient {
    
    func getUserProfile(token: String) async throws -> UserProfileResponse {
        guard let url = URL(string: "http://localhost:3000/auth/profile") else {
            fatalError("Invalid URL" + "http://localhost:3000/auth/profile")
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        let userProfileResponse = try JSONDecoder().decode(UserProfileResponse.self, from: data)
        return userProfileResponse
    }
    
    func updateUserProfile(token: String, name: String?, email: String?) async throws -> UserResponseDto {
        guard let url = URL(string: "http://localhost:3000/users") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Crear diccionario solo con campos no nulos
        var updateDict: [String: String] = [:]
        if let name = name {
            updateDict["name"] = name
        }
        if let email = email {
            updateDict["email"] = email
        }
        
        // Convertir a JSON
        let jsonData = try JSONSerialization.data(withJSONObject: updateDict)
        request.httpBody = jsonData
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 Actualizando perfil: \(jsonString)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 Código de estado: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode >= 400 {
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Error: \(errorString)")
                    throw NSError(domain: "", code: httpResponse.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: "Error al actualizar perfil"])
                }
            }
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Respuesta: \(jsonString)")
        }
        
        let updatedProfile = try JSONDecoder().decode(UserResponseDto.self, from: data)
        return updatedProfile
    }
    
    func updatePassword(token: String, currentPassword: String, newPassword: String) async throws {
        guard let url = URL(string: "http://localhost:3000/users") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Solo enviamos el password
        let updateDict: [String: String] = ["password": newPassword]
        let jsonData = try JSONSerialization.data(withJSONObject: updateDict)
        request.httpBody = jsonData
        
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 Actualizando contraseña: \(jsonString)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 Código de estado: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode >= 400 {
                if let errorString = String(data: data, encoding: .utf8) {
                    print("❌ Error: \(errorString)")
                    throw NSError(domain: "", code: httpResponse.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: "Error al actualizar contraseña"])
                }
            }
        }
    }
}

// Estructura para la respuesta de actualización
struct UserResponseDto: Codable {
    let id: Int
    let email: String
    let name: String
}
