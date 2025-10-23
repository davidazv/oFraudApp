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
    @State private var showMySolicitudes = false
    
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
                        
                        // Botón para ver mis solicitudes
                        Button(action: {
                            showMySolicitudes = true
                        }) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .foregroundColor(.blue)
                                Text("Ver Mis Solicitudes")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                        }
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
                    if alertMessage.contains("exitosamente") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showMySolicitudes) {
                MySupportRequestsView()
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
        
        Task {
            await sendSupportRequest()
        }
    }
    
    private func sendSupportRequest() async {
        isLoading = true
        
        do {
            // Obtener token del usuario
            guard let token = TokenStorage.get(identifier: "accessToken") else {
                await MainActor.run {
                    isLoading = false
                    alertMessage = "No hay sesión activa. Por favor inicia sesión."
                    showingAlert = true
                }
                return
            }
            
            // Mapear prioridades
            let priorityValue: String
            switch priority {
            case "Muy urgente":
                priorityValue = "urgent"
            case "Urgente":
                priorityValue = "normal"
            case "No urgente":
                priorityValue = "low"
            default:
                priorityValue = "normal"
            }
            
            // Crear solicitud JSON
            let requestData: [String: Any] = [
                "title": subject,
                "description": detailedDescription,
                "priority": priorityValue
            ]
            
            let url = URL(string: "http://10.48.246.68:3000/help-requests")!
            var httpRequest = URLRequest(url: url)
            httpRequest.httpMethod = "POST"
            httpRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            httpRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            httpRequest.httpBody = try JSONSerialization.data(withJSONObject: requestData)
            
            print("📤 Enviando solicitud de ayuda...")
            print("🔍 Datos enviados: \(requestData)")
            
            let (data, response) = try await URLSession.shared.data(for: httpRequest)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 Código de estado: \(httpResponse.statusCode)")
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 Respuesta: \(jsonString)")
                }
                
                await MainActor.run {
                    isLoading = false
                    
                    if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                        alertMessage = "Solicitud enviada exitosamente.\n\nNuestro equipo revisará tu solicitud y te responderá pronto."
                        showingAlert = true
                    } else {
                        // Intentar decodificar error
                        if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                            alertMessage = "Error al enviar solicitud: \(errorResponse.errorMessage)"
                        } else {
                            alertMessage = "Error al enviar solicitud. Código: \(httpResponse.statusCode)"
                        }
                        showingAlert = true
                    }
                }
            }
            
        } catch {
            await MainActor.run {
                isLoading = false
                alertMessage = "Error de conexión: \(error.localizedDescription)"
                showingAlert = true
                print("❌ Error completo: \(error)")
            }
        }
    }
}

#Preview {
    RequestSupportView()
}
