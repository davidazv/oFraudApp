//
//  RegistroUsuario452App.swift
//  RegistroUsuario452
//
//  Created by José Molina on 22/08/25.
//

import SwiftUI

//@main
//struct RegistroUsuario452App: App {
//    @AppStorage("isLoggedIn") private var isLoggedIn = false
// var body: some Scene {
//        WindowGroup {
//            if isLoggedIn {
//                HomeScreen()                     // tu pantalla principal
//           } else {
//                NavigationStack { LoginScreen() } // login con navegación a registro
//            }
//        }
//    }
//}


@main
struct RegistroUsuario452App: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                HomeScreen()
            } else {
                ModernLoginScreen()  // Cambiado de LoginScreen a ModernLoginScreen
            }
        }
    }
}
