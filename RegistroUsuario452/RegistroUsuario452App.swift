//
//  RegistroUsuario452App.swift
//  RegistroUsuario452
//
//  Created by José Molina on 22/08/25.
//


import SwiftUI

@main
struct RegistroUsuario452App: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("isGuestMode") private var isGuestMode = false
    
    // Crear instancia compartida del ProfileEnvironment
    @State private var profileEnvironment = ProfileEnvironment.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn && !isGuestMode {
                    // Usuario autenticado
                    HomeScreen()
                } else if isGuestMode {
                    // Modo invitado
                    GuestHomeScreen()
                } else {
                    // No autenticado
                    ModernLoginScreen()
                }
            }
            .environment(\.profileEnvironment, profileEnvironment)
        }
    }
}
