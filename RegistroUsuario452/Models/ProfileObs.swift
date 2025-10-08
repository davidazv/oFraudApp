//
//  ProfileObs.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 13/09/25.
//

import Foundation
import Observation

@Observable
class ProfileObs {
    var name: String = ""
    var email: String = ""
    var password: String = ""
}
