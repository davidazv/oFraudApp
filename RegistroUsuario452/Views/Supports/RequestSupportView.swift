//
//  RequestSupportView.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 03/10/25.
//


import SwiftUI
import PhotosUI

struct RequestSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory = ""
    @State private var priority = "Muy urgente"
    @State private var subject = ""
    @State private var detailedDescription = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var showCategoryPicker = false
    @State private var showPriorityPicker = false
    
    let categories = ["Problema técnico", "Error de la app", "Problema de cuenta", "Sugerencia", "Otro"]
    let priorities = ["Muy urgente", "Urgente", "No urgente"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo azul característico
                Color.blue.opacity(0.05).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header con icono
                        VStack(spacing: 12) {
                            Image(systemName: "headphones.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("Solicitar Soporte Técnico")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Estamos aquí para ayudarte")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            // Categoría del problema
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Categoría del Problema")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                Button(action: {
                                    showCategoryPicker = true
                                }) {
                                    HStack {
                                        Text(selectedCategory.isEmpty ? "Selecciona una categoría" : selectedCategory)
                                            .foregroundColor(selectedCategory.isEmpty ? .gray : .black)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Prioridad
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Prioridad")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                Button(action: {
                                    showPriorityPicker = true
                                }) {
                                    HStack {
                                        Text(priority)
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Asunto
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Asunto")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                TextField("Describe brevemente tu problema", text: $subject)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                            
                            // Descripción detallada
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Descripción Detallada")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                ZStack(alignment: .topLeading) {
                                    if detailedDescription.isEmpty {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Describe tu problema con el mayor detalle")
                                            Text("posible. Incluye pasos para reproducir el")
                                            Text("error, mensajes de error, o cualquier")
                                            Text("información relevante...")
                                        }
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 8)
                                        .padding(.top, 12)
                                    }
                                    
                                    TextEditor(text: $detailedDescription)
                                        .frame(minHeight: 120)
                                        .scrollContentBackground(.hidden)
                                        .padding(4)
                                }
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                            
                            // Adjuntar archivo
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Evidencia (Opcional)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                PhotosPicker(selection: $selectedImage, matching: .images) {
                                    HStack {
                                        Image(systemName: "paperclip")
                                            .foregroundColor(.blue)
                                        Text(selectedImage == nil ? "Adjuntar archivo" : "Archivo adjunto")
                                            .foregroundColor(.blue)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Mensaje informativo
                        VStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                            
                            Text("Una vez enviada tu solicitud, nuestro equipo de soporte será notificado automáticamente y recibirás un ID de ticket para dar seguimiento")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                        }
                        .padding(.vertical, 20)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Botón enviar
                        Button(action: {
                            submitSupport()
                        }) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            } else {
                                Text("Enviar Solicitud")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                        }
                        .background(Color.blue)
                        .cornerRadius(12)
                        .disabled(isLoading)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
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
            .confirmationDialog("Selecciona una categoría", isPresented: $showCategoryPicker, titleVisibility: .visible) {
                ForEach(categories, id: \.self) { category in
                    Button(category) {
                        selectedCategory = category
                    }
                }
            }
            .confirmationDialog("Selecciona la prioridad", isPresented: $showPriorityPicker, titleVisibility: .visible) {
                ForEach(priorities, id: \.self) { priorityOption in
                    Button(priorityOption) {
                        priority = priorityOption
                    }
                }
            }
            .alert("Soporte Técnico", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("Ticket") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func submitSupport() {
        guard !selectedCategory.isEmpty else {
            alertMessage = "Por favor selecciona una categoría"
            showingAlert = true
            return
        }
        
        guard !subject.isEmpty else {
            alertMessage = "Por favor ingresa un asunto"
            showingAlert = true
            return
        }
        
        guard !detailedDescription.isEmpty else {
            alertMessage = "Por favor ingresa una descripción detallada"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        // Simular envío (implementar llamada al backend aquí)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            let ticketID = Int.random(in: 10000...99999)
            alertMessage = "Solicitud enviada exitosamente.\n\nTu ID de ticket es: #\(ticketID)\n\nRecibirás una respuesta pronto."
            showingAlert = true
        }
    }
}

#Preview {
    RequestSupportView()
}
