//
//  LoginScreen.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 05/09/25.
//

import SwiftUI

struct LoginScreen: View {
    @State var email: String = ""
    @State var password: String = ""
    @Environment(\.authController) var authenticationController
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    private func login() async {
        do{
            isLoggedIn = try await authenticationController.loginUser(email: email, password: password)
            print("Usuario login exitoso \(isLoggedIn)")
        }catch{
            print(error.localizedDescription)
        }
        
    }
    var body: some View {
        NavigationStack{
            Form{
                Text("Inicio de sesión")
                    .font(.title)
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                Section{
                    TextField("Correo electrónico", text: $email)
                        .keyboardType(.emailAddress)
                    SecureField("Contraseña", text: $password)
                    
                    Button(action: {
                        Task{
                            await login()
                        }
                        
                    }){
                        Text("Iniciar sesión")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    NavigationLink("Registrarse"){
                        UserRegistration()
                    }
                }
            }
            
        }.navigationTitle("Login")
    }
}

#Preview {
    LoginScreen()
}
