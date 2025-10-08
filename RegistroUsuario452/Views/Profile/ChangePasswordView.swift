//
//  ChangePasswordView.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 03/10/25.
//

import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    private let profileController: ProfileController
    
    init() {
        self.profileController = ProfileController(profileClient: ProfileClient())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("Cambiar Contraseña")
                            .font(.system(size: 24, weight: .bold))
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        // Contraseña actual
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contraseña Actual")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            
                            SecureField("Ingresa tu contraseña actual", text: $currentPassword)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        // Nueva contraseña
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nueva Contraseña")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            
                            SecureField("Ingresa tu nueva contraseña", text: $newPassword)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        // Confirmar contraseña
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirmar Nueva Contraseña")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            
                            SecureField("Confirma tu nueva contraseña", text: $confirmPassword)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Requisitos de contraseña
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Requisitos de Contraseña")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        
                        PasswordRequirementRow(
                            text: "Mínimo 8 caracteres",
                            isMet: newPassword.count >= 8
                        )
                        
                        PasswordRequirementRow(
                            text: "Al menos una letra mayúscula",
                            isMet: containsUppercase(newPassword)
                        )
                        
                        PasswordRequirementRow(
                            text: "Al menos un número",
                            isMet: containsNumber(newPassword)
                        )
                        
                        PasswordRequirementRow(
                            text: "Al menos un carácter especial",
                            isMet: containsSpecialChar(newPassword)
                        )
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                    
                    // Botón actualizar
                    Button(action: {
                        Task {
                            await updatePassword()
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        } else {
                            Text("Actualizar Contraseña")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                    }
                    .background(Color.green)
                    .cornerRadius(12)
                    .disabled(isLoading)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Atrás")
                        }
                        .foregroundColor(.gray)
                    }
                }
            }
            .alert("Contraseña", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("exitosamente") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func updatePassword() async {
        guard !currentPassword.isEmpty else {
            alertMessage = "Por favor ingresa tu contraseña actual"
            showingAlert = true
            return
        }
        
        guard !newPassword.isEmpty else {
            alertMessage = "Por favor ingresa una nueva contraseña"
            showingAlert = true
            return
        }
        
        guard newPassword.count >= 8 else {
            alertMessage = "La contraseña debe tener mínimo 8 caracteres"
            showingAlert = true
            return
        }
        
        guard containsUppercase(newPassword) else {
            alertMessage = "La contraseña debe tener al menos una letra mayúscula"
            showingAlert = true
            return
        }
        
        guard containsNumber(newPassword) else {
            alertMessage = "La contraseña debe tener al menos un número"
            showingAlert = true
            return
        }
        
        guard containsSpecialChar(newPassword) else {
            alertMessage = "La contraseña debe tener al menos un carácter especial"
            showingAlert = true
            return
        }
        
        guard newPassword == confirmPassword else {
            alertMessage = "Las contraseñas no coinciden"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        do {
            try await profileController.updatePassword(
                currentPassword: currentPassword,
                newPassword: newPassword
            )
            
            await MainActor.run {
                alertMessage = "Contraseña actualizada exitosamente"
                showingAlert = true
            }
        } catch {
            alertMessage = "Error al actualizar contraseña: \(error.localizedDescription)"
            showingAlert = true
        }
        
        isLoading = false
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
}

struct PasswordRequirementRow: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? .green : .gray)
                .font(.system(size: 16))
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(isMet ? .green : .gray)
            
            Spacer()
        }
    }
}

#Preview {
    ChangePasswordView()
}
