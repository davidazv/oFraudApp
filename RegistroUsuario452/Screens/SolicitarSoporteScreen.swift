//
//  SolicitarSoporteScreen.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 26/09/25.
//

import SwiftUI

struct SolicitarSoporteScreen: View {
    @State private var categoriaSeleccionada = ""
    @State private var prioridad = "Muy urgente"
    @State private var asunto = ""
    @State private var descripcionDetallada = ""
    @State private var showingImagePicker = false
    @Environment(\.dismiss) private var dismiss
    
    let categorias = ["Problema técnico", "Error de la app", "Problema de cuenta", "Sugerencia", "Otro"]
    let prioridades = ["Muy urgente", "Urgente", "No urgente"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text("Solicitar soporte técnico")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 30)
                }
                .padding(.horizontal)
                .padding(.top)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Categoría del problema
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Categoría del problema")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            
                            HStack {
                                Text(categoriaSeleccionada.isEmpty ? "Selecciona una categoría" : categoriaSeleccionada)
                                    .foregroundColor(categoriaSeleccionada.isEmpty ? .gray : .black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .onTapGesture {
                                // Aquí implementarías el picker de categoría
                            }
                        }
                        
                        // Prioridad
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Prioridad")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            
                            HStack {
                                Text(prioridad)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .onTapGesture {
                                // Aquí implementarías el picker de prioridad
                            }
                        }
                        
                        // Asunto
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Asunto")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            
                            TextField("Describe brevemente tu problema:", text: $asunto)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // Descripción detallada
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción detallada")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                ZStack(alignment: .topLeading) {
                                    if descripcionDetallada.isEmpty {
                                        VStack(alignment: .leading) {
                                            Text("Describe tu problema con el mayor detalle")
                                            Text("posible. Incluye pasos para reproducir el")
                                            Text("error, mensajes de error, o cualquier")
                                            Text("información relevante...")
                                        }
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                    }
                                    
                                    TextEditor(text: $descripcionDetallada)
                                        .frame(minHeight: 120)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.clear)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        
                        // Adjuntar archivo
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Text("Adjuntar archivo (opcional)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.black)
                                .cornerRadius(8)
                        }
                        
                        Spacer(minLength: 20)
                        
                        // Botón enviar
                        Button(action: {
                            // Acción para enviar solicitud
                            print("Enviar solicitud")
                        }) {
                            Text("Enviar solicitud")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        
                        // Texto informativo
                        Text("Una vez enviada tu solicitud, nuestro equipo de soporte será notificado automáticamente y recibirás un ID de ticket para dar seguimiento")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingImagePicker) {
            // Aquí implementarías el ImagePicker
            Text("Image Picker")
        }
    }
}

#Preview("Solicitar Soporte") {
    SolicitarSoporteScreen()
}
