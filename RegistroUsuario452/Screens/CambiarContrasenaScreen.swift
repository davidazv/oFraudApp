//
//  CambiarContrasenaScreen.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 19/09/25.
//

import SwiftUI

struct CambiarContrasenaScreen: View {
    @State private var contrasenaActual = ""
    @State private var nuevaContrasena = ""
    @State private var confirmarContrasena = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header con avatar y nombre
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("JP")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .semibold))
                            )
                        Text("Juan Perez")
                            .font(.headline)
                        Text("Cerrar sesión")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Espacio para balancear
                    Color.clear
                        .frame(width: 30)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Título
                Text("Cambiar contraseña")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                VStack(spacing: 16) {
                    // Campo contraseña actual
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Contraseña actual")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        
                        SecureField("Ingresa tu contraseña actual...", text: $contrasenaActual)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Campo nueva contraseña
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nueva contraseña")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        
                        SecureField("Ingresa tu nueva contraseña...", text: $nuevaContrasena)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Campo confirmar contraseña
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirma nueva contraseña")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        
                        SecureField("Confirma tu nueva contraseña...", text: $confirmarContrasena)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                // Requisitos de contraseña
                VStack(alignment: .leading, spacing: 4) {
                    Text("Requisitos de contraseña")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Image(systemName: nuevaContrasena.count >= 8 ? "checkmark" : "xmark")
                                .foregroundColor(nuevaContrasena.count >= 8 ? .green : .gray)
                                .font(.caption)
                            Text("Mínimo 8 caracteres")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Image(systemName: containsUppercase(nuevaContrasena) ? "checkmark" : "xmark")
                                .foregroundColor(containsUppercase(nuevaContrasena) ? .green : .gray)
                                .font(.caption)
                            Text("Al menos una letra mayúscula")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Image(systemName: containsNumber(nuevaContrasena) ? "checkmark" : "xmark")
                                .foregroundColor(containsNumber(nuevaContrasena) ? .green : .gray)
                                .font(.caption)
                            Text("Al menos un número")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Image(systemName: containsSpecialChar(nuevaContrasena) ? "checkmark" : "xmark")
                                .foregroundColor(containsSpecialChar(nuevaContrasena) ? .green : .gray)
                                .font(.caption)
                            Text("Al menos un carácter especial")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Botón actualizar
                Button(action: {
                    // Acción para actualizar contraseña
                    print("Actualizar contraseña")
                }) {
                    Text("Actualizar contraseña")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarHidden(true)
        }
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

#Preview {
    CambiarContrasenaScreen()
}
