//
//  CreateReportView.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 03/10/25.
//

import SwiftUI
import PhotosUI

struct CreateReportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: CategoryType = .sitioWebBancario
    @State private var title = ""
    @State private var description = ""
    @State private var incidentDate = Date()
    @State private var location = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var isAnonymous = false
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let reportClient = ReportClient()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("Generar Reporte")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        Text("Ayuda a prevenir fraudes reportando incidentes")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    VStack(spacing: 16) {
                        // Tipo de incidente
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tipo de Incidente")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            
                            Picker("Tipo de Incidente", selection: $selectedCategory) {
                                ForEach(CategoryType.allCases) { category in
                                    Text(category.name).tag(category)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // Título
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Título del Reporte")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            
                            TextField("Ej: Llamada fraudulenta de banco", text: $title)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        // Descripción
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción Detallada")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            
                            ZStack(alignment: .topLeading) {
                                if description.isEmpty {
                                    Text("Describe el incidente con el mayor detalle posible...")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 8)
                                        .padding(.top, 12)
                                }
                                
                                TextEditor(text: $description)
                                    .frame(minHeight: 120)
                                    .scrollContentBackground(.hidden)
                                    .padding(4)
                            }
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // Fecha del incidente
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fecha del Incidente")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            
                            DatePicker("", selection: $incidentDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        // Ubicación (opcional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ubicación (Opcional)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            
                            TextField("Ej: Ciudad de México", text: $location)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        // Evidencia (imagen)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Evidencia (Opcional)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            
                            PhotosPicker(selection: $selectedImage, matching: .images) {
                                HStack {
                                    Image(systemName: "photo")
                                    Text(selectedImage == nil ? "Seleccionar imagen" : "Imagen seleccionada")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Reporte anónimo
                        Toggle(isOn: $isAnonymous) {
                            Text("Enviar como anónimo")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Botón enviar
                    Button(action: {
                        Task {
                            await submitReport()
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        } else {
                            Text("Enviar Reporte")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                    }
                    .background(Color.red)
                    .cornerRadius(12)
                    .disabled(isLoading)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .alert("Reporte", isPresented: $showingAlert) {
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
    
    private func submitReport() async {
        guard !title.isEmpty else {
            alertMessage = "Por favor ingresa un título"
            showingAlert = true
            return
        }
        
        guard !description.isEmpty else {
            alertMessage = "Por favor ingresa una descripción"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        do {
            guard let token = TokenStorage.get(identifier: "accessToken") else {
                throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"])
            }
            
            // Formato de fecha correcto: yyyy-MM-dd (sin hora)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = TimeZone.current
            
            let reportRequest = CreateReportRequest(
                categoryId: selectedCategory.id,
                title: title,
                description: description,
                incidentDate: dateFormatter.string(from: incidentDate),
                location: location.isEmpty ? nil : location,
                evidenceUrl: nil,
                isAnonymous: isAnonymous
            )
            
            let _ = try await reportClient.createReport(token: token, report: reportRequest)
            alertMessage = "Reporte enviado exitosamente"
            showingAlert = true
        } catch {
            alertMessage = "Error al enviar reporte: \(error.localizedDescription)"
            showingAlert = true
        }
        
        isLoading = false
    }
}

#Preview {
    CreateReportView()
}
