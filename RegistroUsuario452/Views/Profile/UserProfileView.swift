//
//  UserProfileView.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 03/10/25.
//

import SwiftUI

struct UserProfileView: View {
    @Environment(\.profileEnvironment) var profileEnv
    @Environment(\.dismiss) var dismiss
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
                                        Text(getInitials(from: profileEnv.profile.name))
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                
                                Text(profileEnv.profile.name)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Text(profileEnv.profile.email)
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 20)
                            // Forzar actualización cuando cambia el perfil
                            .id(profileEnv.profile.name + profileEnv.profile.email + "\(profileEnv.needsRefresh)")
                            
                            // Botón editar perfil
                            Button(action: {
                                editedName = profileEnv.profile.name
                                editedEmail = profileEnv.profile.email
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
            .navigationTitle("Mi Perfil")
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
            .task {
                // Solo cargar si el perfil está vacío
                if profileEnv.profile.name.isEmpty || profileEnv.profile.email.isEmpty {
                    await loadProfile()
                }
            }
            .alert("Perfil", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $isEditing) {
                EditProfileSheet(
                    profileEnv: profileEnv,
                    editedName: $editedName,
                    editedEmail: $editedEmail,
                    isUpdating: $isUpdating,
                    showingAlert: $showingAlert,
                    alertMessage: $alertMessage
                )
            }
        }
    }
    
    private func loadProfile() async {
        isLoading = true
        do {
            let p = try await profileController.getProfile()
            await MainActor.run {
                profileEnv.profile.email = p.email
                profileEnv.profile.name = p.name
                profileEnv.profile.password = p.passwordHash
            }
        } catch {
            alertMessage = "Error al cargar perfil: \(error.localizedDescription)"
            showingAlert = true
        }
        isLoading = false
    }
    
    private func getInitials(from name: String) -> String {
        guard !name.isEmpty else {
            return "U"
        }
        
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

struct EditProfileSheet: View {
    let profileEnv: ProfileEnvironment
    @Binding var editedName: String
    @Binding var editedEmail: String
    @Binding var isUpdating: Bool
    @Binding var showingAlert: Bool
    @Binding var alertMessage: String
    @Environment(\.dismiss) var dismiss
    
    private let profileController: ProfileController
    
    init(profileEnv: ProfileEnvironment, editedName: Binding<String>, editedEmail: Binding<String>, isUpdating: Binding<Bool>, showingAlert: Binding<Bool>, alertMessage: Binding<String>) {
        self.profileEnv = profileEnv
        self._editedName = editedName
        self._editedEmail = editedEmail
        self._isUpdating = isUpdating
        self._showingAlert = showingAlert
        self._alertMessage = alertMessage
        self.profileController = ProfileController(profileClient: ProfileClient())
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Formulario de edición
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nombre")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.leading, 8)
                        
                        TextField("Nombre", text: $editedName)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Correo Electrónico")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.leading, 8)
                        
                        TextField("Correo", text: $editedEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Botones
                VStack(spacing: 12) {
                    Button(action: {
                        Task {
                            await updateProfile()
                        }
                    }) {
                        if isUpdating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Guardar Cambios")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(isUpdating)
                    
                    Button("Cancelar") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .disabled(isUpdating)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationTitle("Editar Perfil")
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
            .alert("Perfil", isPresented: $showingAlert) {
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
            let nameToUpdate = editedName != profileEnv.profile.name ? editedName : nil
            let emailToUpdate = editedEmail != profileEnv.profile.email ? editedEmail : nil
            
            let updatedProfile = try await profileController.updateProfile(
                name: nameToUpdate,
                email: emailToUpdate
            )
            
            await MainActor.run {
                // CRÍTICO: Actualizar el perfil global INMEDIATAMENTE
                profileEnv.profile.name = updatedProfile.name
                profileEnv.profile.email = updatedProfile.email
                
                // Forzar actualización del UI
                profileEnv.needsRefresh.toggle()
                
                alertMessage = "Perfil actualizado exitosamente"
                showingAlert = true
            }
        } catch {
            alertMessage = "Error al actualizar perfil: \(error.localizedDescription)"
            showingAlert = true
        }
        
        isUpdating = false
    }
}

#Preview {
    UserProfileView()
}
