//
//  ProfileEnvironment.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 06/10/25.
//

import SwiftUI

// Modelo observable del perfil
@Observable
class ProfileData {
    var name: String = ""
    var email: String = ""
    var password: String = ""
}

// Environment observable
@Observable
class ProfileEnvironment {
    var profile = ProfileData()
    var needsRefresh = false
}

// Extension para usar como Environment
extension ProfileEnvironment {
    static let shared = ProfileEnvironment()
}

// EnvironmentKey
private struct ProfileEnvironmentKey: EnvironmentKey {
    static let defaultValue = ProfileEnvironment.shared
}

extension EnvironmentValues {
    var profileEnvironment: ProfileEnvironment {
        get { self[ProfileEnvironmentKey.self] }
        set { self[ProfileEnvironmentKey.self] = newValue }
    }
}
