//
//  ProfileEnvironment.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 06/10/25.
//

import SwiftUI

@Observable
class ProfileEnvironment {
    var profile: ProfileObs = ProfileObs()
    var needsRefresh: Bool = false
}

extension EnvironmentValues {
    @Entry var profileEnvironment = ProfileEnvironment()
}
