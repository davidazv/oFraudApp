//
//  ModernRegistrationScreen.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 30/09/25.
//

import SwiftUI

struct ModernRegistrationScreen: View {
    @Environment(\.authController) var authenticationController
    @Environment(\.dismiss) var dismiss
    @State private var nombre: String = ""
    @State private var apellido: String = ""
    @State private var correo: String = ""
    @State private var contraseña: String = ""
    @State private var confirmarContraseña: String = ""
    @State private var errorMessages: [String] = []
    @State private var showingAlert = false
    @State private var isLoading = false
    
    private func register() async {
        isLoading = true
        do {
            // Combinar nombre y apellido
            let fullName = "\(nombre) \(apellido)"
            let response = try await authenticationController.registerUser(
                name: fullName,
                email: correo,
                password: contraseña
            )
            print("Usuario registrado: \(response)")
            isLoading = false
            
            // Regresar a la pantalla de login sin auto-login
            await MainActor.run {
                dismiss()
            }
        } catch {
            errorMessages = ["Error al registrarte: \(error.localizedDescription)"]
            showingAlert = true
            isLoading = false
            print("Error al registrarte: \(error)")
        }
    }
    
    private func validate() -> [String] {
        var errors: [String] = []
        
        if nombre.isEmpty {
            errors.append("El nombre es requerido")
        }
        
        if apellido.isEmpty {
            errors.append("El apellido es requerido")
        }
        
        if correo.isEmpty {
            errors.append("El correo es requerido")
        } else if !correo.contains("@") || !correo.contains(".") {
            errors.append("El correo no es válido")
        }
        
        if contraseña.isEmpty {
            errors.append("La contraseña es requerida")
        } else {
            if contraseña.count < 10 {
                errors.append("La contraseña debe tener mínimo 10 caracteres")
            }
            if !containsUppercase(contraseña) {
                errors.append("La contraseña debe tener al menos una letra mayúscula")
            }
            if !containsNumber(contraseña) {
                errors.append("La contraseña debe tener al menos un número")
            }
            if !containsSpecialChar(contraseña) {
                errors.append("La contraseña debe tener al menos un carácter especial")
            }
        }
        
        if confirmarContraseña.isEmpty {
            errors.append("Debes confirmar la contraseña")
        } else if contraseña != confirmarContraseña {
            errors.append("Las contraseñas no coinciden")
        }
        
        return errors
    }
    
    private func containsUppercase(_ string: String) -> Bool {
        return string.range(of: "[A-Z]", options: .regularExpression) != nil
    }
    
    private func containsNumber(_ string: String) -> Bool {
        return string.range(of: "[0-9]", options: .regularExpression) != nil
    }
    
    private func containsSpecialChar(_ string: String) -> Bool {
        return string.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Logo oFraud
                    Text("oFraud")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.red)
                        .padding(.top, 40)
                    
                    // Título
                    Text("Crea una cuenta")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.top, 40)
                        .padding(.bottom, 30)
                    
                    // Campos de entrada
                    VStack(spacing: 16) {
                        TextField("Nombre", text: $nombre)
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 32)
                        
                        TextField("Apellido", text: $apellido)
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 32)
                        
                        TextField("Correo electrónico", text: $correo)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 32)
                        
                        SecureField("Contraseña", text: $contraseña)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textContentType(.newPassword)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 32)
                        
                        SecureField("Confirmar contraseña", text: $confirmarContraseña)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textContentType(.newPassword)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 32)
                    }
                    .textContentType(.none)
                    .padding(.bottom, 20)
                    
                    // Requisitos de contraseña
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Requisitos de contraseña")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.horizontal, 32)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Image(systemName: contraseña.count >= 10 ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(contraseña.count >= 10 ? .green : .red)
                                    .font(.system(size: 14))
                                Text("Mínimo 10 caracteres")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: containsUppercase(contraseña) ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(containsUppercase(contraseña) ? .green : .red)
                                    .font(.system(size: 14))
                                Text("Al menos una letra mayúscula")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: containsNumber(contraseña) ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(containsNumber(contraseña) ? .green : .red)
                                    .font(.system(size: 14))
                                Text("Al menos un número")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            HStack(spacing: 8) {
                                Image(systemName: containsSpecialChar(contraseña) ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(containsSpecialChar(contraseña) ? .green : .red)
                                    .font(.system(size: 14))
                                Text("Al menos un carácter especial")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 32)
                    
                    // Botón Continuar
                    Button(action: {
                        errorMessages = validate()
                        if errorMessages.isEmpty {
                            Task {
                                await register()
                            }
                        } else {
                            showingAlert = true
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        } else {
                            Text("Continuar")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                    }
                    .background(Color.black)
                    .cornerRadius(12)
                    .disabled(isLoading)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.light)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Sign In")
                    }
                    .foregroundColor(.gray)
                }
            }
        }
        .alert("Validación", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessages.joined(separator: "\n"))
        }
    }
}

#Preview {
    NavigationStack {
        ModernRegistrationScreen()
    }
}
