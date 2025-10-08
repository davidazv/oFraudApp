//
//  CerrarSesionScreen.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 26/09/25.
//

import SwiftUI

struct CerrarSesionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingLogoutConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header con avatar y nombre
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(.black)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text("oFraud")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    HStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("JP")
                                    .foregroundColor(.white)
                                    .font(.system(size: 12, weight: .semibold))
                            )
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Juan Perez")
                                .font(.system(size: 14, weight: .medium))
                            Text("Cerrar sesión")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                
                // Contenido principal
                VStack(spacing: 30) {
                    Text("Cerrar sesión")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Text("Confirmar para cerrar sesión.")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(.horizontal, 40)
                    
                    VStack(spacing: 16) {
                        // Botón Cancelar
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancelar")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        // Botón Cerrar sesión
                        Button(action: {
                            showingLogoutConfirmation = true
                        }) {
                            Text("Cerrar sesión")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .alert("Cerrar Sesión", isPresented: $showingLogoutConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Cerrar Sesión", role: .destructive) {
                // Aquí implementarías la lógica de cerrar sesión
                // Por ejemplo, limpiar datos del usuario, navegar a login, etc.
                print("Cerrando sesión...")
            }
        } message: {
            Text("¿Estás seguro que deseas cerrar sesión?")
        }
    }
}

#Preview("Cerrar Sesión") {
    CerrarSesionScreen()
}
