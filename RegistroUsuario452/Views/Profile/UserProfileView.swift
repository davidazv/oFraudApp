//
//  UserProfileView.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 03/10/25.
//

import SwiftUI

struct UserProfileView: View {
    @Environment(\.profileEnvironment) var profileEnv
    @State private var profile = ProfileObs()
    @State private var isLoading = false
    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedEmail = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isUpdating = false
    
    private let profileController: ProfileController
    
    init() {
        self.profileController = ProfileController(profileClient: ProfileClient())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Cargando perfil...")
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Avatar y nombre
                            VStack(spacing: 12) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Text(getInitials(from: profile.name))
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                
                                if !isEditing {
                                    Text(profile.name)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.black)
                                    
                                    Text(profile.email)
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 20)
                            
                            if isEditing {
                                // Formulario de edición
                                VStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Nombre")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.black)
                                        
                                        TextField("Nombre", text: $editedName)
                                            .padding()
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(12)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Correo Electrónico")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.black)
                                        
                                        TextField("Correo", text: $editedEmail)
                                            .keyboardType(.emailAddress)
                                            .autocapitalization(.none)
                                            .padding()
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(12)
                                    }
                                    
                                    HStack(spacing: 12) {
                                        Button("Cancelar") {
                                            isEditing = false
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.black)
                                        .cornerRadius(12)
                                        .disabled(isUpdating)
                                        
                                        Button(action: {
                                            Task {
                                                await updateProfile()
                                            }
                                        }) {
                                            if isUpdating {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            } else {
                                                Text("Guardar")
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .disabled(isUpdating)
                                    }
                                }
                                .padding(.horizontal)
                            } else {
                                // Botón editar perfil
                                Button(action: {
                                    editedName = profile.name
                                    editedEmail = profile.email
                                    isEditing = true
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Editar Perfil")
                                    }
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Mi Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadProfile()
            }
            .alert("Perfil", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func loadProfile() async {
        isLoading = true
        do {
            let p = try await profileController.getProfile()
            await MainActor.run {
                profile.email = p.email
                profile.name = p.name
                profile.password = p.passwordHash
            }
        } catch {
            alertMessage = "Error al cargar perfil: \(error.localizedDescription)"
            showingAlert = true
        }
        isLoading = false
    }
    
    private func updateProfile() async {
        guard !editedName.isEmpty else {
            alertMessage = "El nombre no puede estar vacío"
            showingAlert = true
            return
        }
        
        guard !editedEmail.isEmpty else {
            alertMessage = "El correo no puede estar vacío"
            showingAlert = true
            return
        }
        
        guard editedEmail.contains("@") && editedEmail.contains(".") else {
            alertMessage = "El correo no es válido"
            showingAlert = true
            return
        }
        
        isUpdating = true
        
        do {
            // Solo enviamos los campos que cambiaron
            let nameToUpdate = editedName != profile.name ? editedName : nil
            let emailToUpdate = editedEmail != profile.email ? editedEmail : nil
            
            let updatedProfile = try await profileController.updateProfile(
                name: nameToUpdate,
                email: emailToUpdate
            )
            
            await MainActor.run {
                profile.name = updatedProfile.name
                profile.email = updatedProfile.email
                
                // Actualizar el ambiente global
                profileEnv.profile.name = updatedProfile.name
                profileEnv.profile.email = updatedProfile.email
                profileEnv.needsRefresh = true
                
                isEditing = false
                alertMessage = "Perfil actualizado exitosamente"
                showingAlert = true
            }
        } catch {
            alertMessage = "Error al actualizar perfil: \(error.localizedDescription)"
            showingAlert = true
        }
        
        isUpdating = false
    }
    
    private func getInitials(from name: String) -> String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            let first = String(components[0].prefix(1))
            let last = String(components[1].prefix(1))
            return "\(first)\(last)".uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        return "U"
    }
}

#Preview {
    UserProfileView()
}
