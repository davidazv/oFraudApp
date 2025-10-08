//
//  ProfileController.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 13/09/25.
//

//
//  ProfileController.swift
//  RegistroUsuario452
//

import Foundation
import Combine

struct ProfileController {
    
    private var profileClient = ProfileClient()
    
    init(profileClient: ProfileClient) {
        self.profileClient = profileClient
    }
    
    func getProfile() async throws -> Profile {
        let accessToken = TokenStorage.get(identifier: "accessToken")
        let response = try await profileClient.getUserProfile(token: accessToken!)
        return response.profile
    }
    
    func updateProfile(name: String?, email: String?) async throws -> UserResponseDto {
        guard let accessToken = TokenStorage.get(identifier: "accessToken") else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"])
        }
        
        let updatedProfile = try await profileClient.updateUserProfile(
            token: accessToken,
            name: name,
            email: email
        )
        return updatedProfile
    }
    func updatePassword(currentPassword: String, newPassword: String) async throws {
        guard let accessToken = TokenStorage.get(identifier: "accessToken") else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"])
        }
        
        // Nota: Tu backend no valida la contraseña actual en el endpoint PUT /users
        // Solo actualiza con la nueva contraseña
        try await profileClient.updatePassword(
            token: accessToken,
            currentPassword: currentPassword,
            newPassword: newPassword
        )
    }
}
