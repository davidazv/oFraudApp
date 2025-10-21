//
//  GuestHomeScreen.swift
//  RegistroUsuario452
//
//  Created by Claude on 08/10/25.
//

import SwiftUI

struct GuestHomeScreen: View {
    @AppStorage("isGuestMode") var isGuestMode: Bool = false
    @State private var showCreateReport = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Text("oFraud")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.red)
                    
                    Text("Modo Invitado")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("Como invitado puedes generar reportes anónimos\npara ayudar a prevenir fraudes")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Botón principal para crear reporte
                Button(action: {
                    showCreateReport = true
                }) {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.red.opacity(0.3), radius: 12, x: 0, y: 8)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Generar Reporte")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                
                // Información sobre limitaciones
                VStack(spacing: 12) {
                    Text("Limitaciones del modo invitado:")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Puedes crear reportes anónimos")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("No puedes ver historial de reportes")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("No tienes acceso a reportes públicos")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                }
                .padding(20)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Botón para crear cuenta o iniciar sesión
                VStack(spacing: 12) {
                    Text("¿Quieres acceso completo?")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        // Limpiar cualquier estado de login previo y tokens
                        UserDefaults.standard.set(false, forKey: "isLoggedIn")
                        UserDefaults.standard.removeObject(forKey: "accessToken")
                        UserDefaults.standard.removeObject(forKey: "refreshToken")
                        isGuestMode = false
                    }) {
                        Text("Crear cuenta o Iniciar sesión")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.black)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showCreateReport) {
            CreateReportView(isGuestMode: true)
        }
    }
}

#Preview {
    GuestHomeScreen()
}