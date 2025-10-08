//
//  ProfileView.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 12/09/25.
//


import SwiftUI

struct ProfileView: View {
    var profileController: ProfileController
    @State var profile = ProfileObs()
    init () {
        
            self.profileController = ProfileController(profileClient: ProfileClient())
        
    }
    private func loadProfile() async {
        do {
            let p = try await profileController.getProfile()
                await MainActor.run {
                    profile.email = p.email
                    profile.name = p.name
                    profile.password = p.passwordHash
                }
            } catch {
                print("Error al cargar perfil:", error)
            }
        }
    var body: some View {
        @Bindable var profile = profile
        Form{
            TextField("Nombre", text: $profile.name)
            TextField("Correo", text: $profile.email)
            //SecureField("Contraseña", text: $profile.password)
            Button("Update") {
                }
        }
        .task { await loadProfile() }
        //.refreshable { await loadProfile() }
    }
}

/**let id: Int
 let email, name, passwordHash, salt: String*/
#Preview {
    ProfileView()
}
