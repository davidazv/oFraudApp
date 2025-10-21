//
//  URLSettings.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 13/09/25.
//

import Foundation

struct URLSettings {
    static let server = "http://192.168.0.100:3000"
    static let register = String(server + "/users")
    static let login = String(server + "/auth/login")
    static let profile = String(server + "/auth/profile")
    static let reports = String(server + "/reports")
    static let acceptedReports = String(server + "/reports/public/accepted")
    static let myReports = String(server + "/reports/my-reports")  // ACTUALIZADO
}
