//
//  ProfileMenuView.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 03/10/25.
//

import SwiftUI

struct ProfileMenuView: View {
    @Environment(\.profileEnvironment) var profileEnv
    @State private var isLoading = false
    @State private var showUserProfile = false
    @State private var showMyReports = false
    @State private var showRequestSupport = false
    @State private var showChangePassword = false
    @State private var showLogoutConfirmation = false
    
    private let profileController: ProfileController
    
    init() {
        self.profileController = ProfileController(profileClient: ProfileClient())
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Cargando...")
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header con información del usuario
                            VStack(spacing: 16) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Text(getInitials(from: profileEnv.profile.name))
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(spacing: 4) {
                                    Text(profileEnv.profile.name)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    Text(profileEnv.profile.email)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 30)
                            .padding(.bottom, 30)
                            // ACTUALIZACIÓN: Agregamos un id para forzar la reconstrucción
                            .id(profileEnv.profile.name + profileEnv.profile.email + "\(profileEnv.needsRefresh)")
                            
                            // Opciones del menú
                            VStack(spacing: 0) {
                                ProfileMenuItem(
                                    icon: "person.circle",
                                    title: "Mi Perfil",
                                    color: .blue
                                ) {
                                    showUserProfile = true
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                ProfileMenuItem(
                                    icon: "doc.text",
                                    title: "Mis Reportes",
                                    color: .purple
                                ) {
                                    showMyReports = true
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                ProfileMenuItem(
                                    icon: "questionmark.circle",
                                    title: "Solicitar Ayuda",
                                    color: .orange
                                ) {
                                    showRequestSupport = true
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                ProfileMenuItem(
                                    icon: "lock.rotation",
                                    title: "Cambiar Contraseña",
                                    color: .green
                                ) {
                                    showChangePassword = true
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                ProfileMenuItem(
                                    icon: "rectangle.portrait.and.arrow.right",
                                    title: "Cerrar Sesión",
                                    color: .red
                                ) {
                                    showLogoutConfirmation = true
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                // Solo cargar si el perfil está vacío
                if profileEnv.profile.name.isEmpty || profileEnv.profile.email.isEmpty {
                    await loadProfile()
                }
            }
            .onChange(of: profileEnv.needsRefresh) { _, _ in
                // La vista se actualiza automáticamente por el cambio en @Observable
                // No necesitamos hacer nada adicional aquí
            }
            .sheet(isPresented: $showUserProfile) {
                UserProfileView()
            }
            .sheet(isPresented: $showMyReports) {
                UserReportsView()
            }
            .sheet(isPresented: $showRequestSupport) {
                RequestSupportView()
            }
            .sheet(isPresented: $showChangePassword) {
                ChangePasswordView()
            }
            .sheet(isPresented: $showLogoutConfirmation) {
                LogoutConfirmationView()
            }
            .preferredColorScheme(.light)
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
            print("Error al cargar perfil: \(error)")
        }
        isLoading = false
    }
    
    private func getInitials(from name: String) -> String {
        // Manejo especial para nombres vacíos
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

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
        }
    }
}

#Preview {
    ProfileMenuView()
}
