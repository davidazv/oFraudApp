//
//  LogoutConfirmationView.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 03/10/25.
//

import SwiftUI

struct LogoutConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var showingFinalConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Icono de advertencia
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 80))
                        .foregroundColor(.red)
                    
                    // Título y mensaje
                    VStack(spacing: 12) {
                        Text("Cerrar Sesión")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("Confirmar para cerrar sesión.")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                    
                    // Botones
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
                                .cornerRadius(12)
                        }
                        
                        // Botón Cerrar sesión
                        Button(action: {
                            showingFinalConfirmation = true
                        }) {
                            Text("Cerrar Sesión")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
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
            .alert("Cerrar Sesión", isPresented: $showingFinalConfirmation) {
                Button("Cancelar", role: .cancel) { }
                Button("Cerrar Sesión", role: .destructive) {
                    performLogout()
                }
            } message: {
                Text("¿Estás seguro que deseas cerrar sesión?")
            }
        }
    }
    
    private func performLogout() {
        // Limpiar tokens
        TokenStorage.delete(identifier: "accessToken")
        TokenStorage.delete(identifier: "refreshToken")
        
        // Actualizar estado de login
        isLoggedIn = false
        
        // Cerrar la vista
        dismiss()
    }
}

#Preview {
    LogoutConfirmationView()
}
