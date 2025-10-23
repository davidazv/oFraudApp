//
//  CreateReportView.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 03/10/25.
//

import SwiftUI
import PhotosUI

struct CreateReportView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isGuestMode") var isGuestMode: Bool = false
    @State private var selectedCategory: CategoryType?
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var incidentDate = Date()
    @State private var location: String = ""
    @State private var contactInfo: String = ""
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var uploadedImages: [UIImage] = []
    @State private var isAnonymous: Bool = false
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showCategoryPicker = false
    
    private let reportClient = ReportClient()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.shield")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                            
                            Text("Crear Reporte")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            
                            if isGuestMode {
                                Text("Modo Invitado")
                                    .font(.system(size: 14))
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            // Categoría del fraude
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tipo de Fraude *")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                Button(action: {
                                    showCategoryPicker = true
                                }) {
                                    HStack {
                                        if let category = selectedCategory {
                                            Text(category.name)
                                                .foregroundColor(.black)
                                        } else {
                                            Text("Selecciona el tipo de fraude")
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedCategory == nil ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
                                    )
                                }
                            }
                            
                            // Título del reporte
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Título del Reporte *")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Text("\(title.count)/255")
                                        .font(.system(size: 12))
                                        .foregroundColor(title.count < 10 ? .red : title.count > 255 ? .red : .gray)
                                }
                                
                                TextField("Ej: Me llegó un mensaje de BBVA en Instagram", text: $title)
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(title.count < 10 || title.count > 255 ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
                                    )
                                
                                if title.count < 10 && !title.isEmpty {
                                    Text("Mínimo 10 caracteres")
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                } else if title.count > 255 {
                                    Text("Máximo 255 caracteres")
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                }
                            }
                            
                            // Descripción detallada
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Descripción Detallada *")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Text("\(description.count) caracteres")
                                        .font(.system(size: 12))
                                        .foregroundColor(description.count < 20 ? .red : .gray)
                                }
                                
                                ZStack(alignment: .topLeading) {
                                    if description.isEmpty {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Describe detalladamente lo ocurrido...")
                                                .foregroundColor(.gray)
                                                .padding(.horizontal, 8)
                                                .padding(.top, 12)
                                        }
                                    }
                                    
                                    TextEditor(text: $description)
                                        .foregroundColor(.black)
                                        .frame(minHeight: 120)
                                        .scrollContentBackground(.hidden)
                                        .padding(4)
                                }
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(description.count < 20 ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
                                )
                                
                                if description.count < 20 && !description.isEmpty {
                                    Text("Mínimo 20 caracteres")
                                        .font(.system(size: 12))
                                        .foregroundColor(.red)
                                }
                            }
                            
                            // Fecha del incidente
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Fecha del Incidente *")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                DatePicker("", selection: $incidentDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                            
                            // Información de contacto/URL del fraude
                            VStack(alignment: .leading, spacing: 8) {
                                Text("URL/Número/Email del Fraude *")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                TextField(selectedCategory?.contactPlaceholder ?? "Ej: www.sitio-falso.com", text: $contactInfo)
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                            
                            // Ubicación física
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ubicación del Incidente *")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                TextField("Ej: Ciudad de México, CDMX", text: $location)
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                            
                            // Evidencia
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Evidencia (Opcional)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                // Selector de imágenes
                                PhotosPicker(selection: $selectedImages, maxSelectionCount: 3, matching: .images) {
                                    HStack {
                                        Image(systemName: "photo.badge.plus")
                                            .foregroundColor(.blue)
                                        Text("Agregar imágenes (máx. 3)")
                                            .foregroundColor(.blue)
                                        Spacer()
                                        if !uploadedImages.isEmpty {
                                            Text("\(uploadedImages.count)")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue)
                                                .cornerRadius(10)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                                .onChange(of: selectedImages) { oldValue, newValue in
                                    Task {
                                        await loadSelectedImages()
                                    }
                                }
                                
                                // Vista previa de imágenes seleccionadas
                                if !uploadedImages.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(Array(uploadedImages.enumerated()), id: \.offset) { index, image in
                                                ZStack(alignment: .topTrailing) {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 80, height: 80)
                                                        .clipped()
                                                        .cornerRadius(8)
                                                    
                                                    Button(action: {
                                                        removeImage(at: index)
                                                    }) {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundColor(.red)
                                                            .background(Color.white)
                                                            .clipShape(Circle())
                                                    }
                                                    .offset(x: 8, y: -8)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            // Enviar como anónimo (solo para usuarios registrados)
                            if !isGuestMode {
                                VStack(alignment: .leading, spacing: 8) {
                                    Toggle(isOn: $isAnonymous) {
                                        HStack {
                                            Text("Enviar como anónimo")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.black)
                                            
                                            Image(systemName: "questionmark.circle")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    
                                    if isAnonymous {
                                        Text("Tu identidad no será visible en el reporte público")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 16)
                                    }
                                }
                            } else {
                                // Nota para invitados
                                HStack(spacing: 12) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.orange)
                                    Text("Los reportes de invitados son siempre anónimos")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Nota informativa
                        VStack(spacing: 8) {
                            Text("* Campos obligatorios")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                            
                            Text("La evidencia es opcional pero ayuda a validar tu reporte")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
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
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Nuevo Reporte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
            .confirmationDialog("Selecciona el tipo de fraude", isPresented: $showCategoryPicker, titleVisibility: .visible) {
                ForEach(CategoryType.allCases) { category in
                    Button(category.name) {
                        selectedCategory = category
                    }
                }
                Button("Cancelar", role: .cancel) { }
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {
                    if alertTitle == "Reporte" && alertMessage.contains("exitosamente") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .preferredColorScheme(.light)
        }
    }
    
    private func validateForm() -> [String] {
        var errors: [String] = []
        
        if selectedCategory == nil {
            errors.append("Debes seleccionar un tipo de fraude")
        }
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            errors.append("El título es obligatorio")
        } else if trimmedTitle.count < 10 {
            errors.append("El título debe tener al menos 10 caracteres")
        } else if trimmedTitle.count > 255 {
            errors.append("El título debe tener máximo 255 caracteres")
        }
        
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedDescription.isEmpty {
            errors.append("La descripción es obligatoria")
        } else if trimmedDescription.count < 20 {
            errors.append("La descripción debe tener al menos 20 caracteres")
        }
        
        // NUEVAS VALIDACIONES OBLIGATORIAS
        if contactInfo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("La URL/número/email del fraude es obligatorio")
        }
        
        if location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("La ubicación del incidente es obligatoria")
        }
        
        // Validar fecha con tolerancia para zona horaria
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: incidentDate)
        
        if selectedDay > today {
            errors.append("La fecha del incidente no puede ser futura")
        }
        
        // Debug para modo invitado
        if isGuestMode {
            print("🔍 Validación modo invitado:")
            print("  - Categoría: \(selectedCategory?.name ?? "No seleccionada")")
            print("  - Título: '\(title.trimmingCharacters(in: .whitespacesAndNewlines))'")
            print("  - Descripción: '\(description.trimmingCharacters(in: .whitespacesAndNewlines))'")
            print("  - Fecha seleccionada: \(selectedDay)")
            print("  - Fecha actual: \(today)")
            print("  - Errores encontrados: \(errors)")
        }
        
        return errors
    }
    
    private func submitReport() async {
        // Validar formulario
        let errors = validateForm()
        if !errors.isEmpty {
            alertTitle = "Campos incompletos"
            alertMessage = errors.joined(separator: "\n")
            showingAlert = true
            return
        }
        
        isLoading = true
        
        do {
            // 1. Preparar datos del reporte
            guard let categoryId = selectedCategory?.id else {
                throw NSError(domain: "ReportError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Categoría no seleccionada"])
            }
            
            // 2. Obtener token si no es invitado
            let token = isGuestMode ? "" : (TokenStorage.get(identifier: "accessToken") ?? "")
            
            // 3. Formatear fecha al formato ISO 8601
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let formattedDate = dateFormatter.string(from: incidentDate)
            
            // 4. Preparar imágenes como Data
            var imagesData: [Data] = []
            for image in uploadedImages {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    imagesData.append(imageData)
                }
            }
            
            // 5. Enviar reporte (JSON si no hay imágenes, multipart si hay imágenes)
            let _ = if imagesData.isEmpty {
                try await createReportWithJSON(
                    categoryId: categoryId,
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                    incidentDate: formattedDate,
                    location: location.trimmingCharacters(in: .whitespacesAndNewlines),
                    fraudContact: contactInfo.trimmingCharacters(in: .whitespacesAndNewlines),
                    isAnonymous: isGuestMode ? true : isAnonymous,
                    token: token
                )
            } else {
                try await createReportWithMultipart(
                    categoryId: categoryId,
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                    incidentDate: formattedDate,
                    location: location.trimmingCharacters(in: .whitespacesAndNewlines),
                    fraudContact: contactInfo.trimmingCharacters(in: .whitespacesAndNewlines),
                    isAnonymous: isGuestMode ? true : isAnonymous,
                    token: token,
                    images: imagesData
                )
            }
            
            await MainActor.run {
                isLoading = false
                alertTitle = "Reporte"
                alertMessage = "Tu reporte ha sido enviado exitosamente. Será revisado por nuestro equipo."
                showingAlert = true
            }
            
        } catch {
            await MainActor.run {
                isLoading = false
                alertTitle = "Error"
                
                // Mejorar mensajes de error
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        alertMessage = "No hay conexión a internet"
                    case .cannotConnectToHost:
                        alertMessage = "No se puede conectar al servidor. Verifica que el backend esté ejecutándose."
                    default:
                        alertMessage = "Error de conexión: \(urlError.localizedDescription)"
                    }
                } else {
                    alertMessage = "Error al enviar reporte: \(error.localizedDescription)"
                }
                
                showingAlert = true
                print("❌ Error completo: \(error)")
            }
        }
    }
    
    private func uploadImage(_ photoItem: PhotosPickerItem) async throws -> String {
        // Cargar la imagen desde PhotosPickerItem
        guard let data = try? await photoItem.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else {
            throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No se pudo cargar la imagen"])
        }
        
        // Obtener token
        let token = isGuestMode ? "" : (TokenStorage.get(identifier: "accessToken") ?? "")
        
        // Subir imagen
        let imageURL = try await reportClient.uploadImage(token: token, image: uiImage)
        print("✅ Imagen subida: \(imageURL)")
        
        return imageURL
    }
    
    // MARK: - Funciones para manejo de imágenes
    
    private func loadSelectedImages() async {
        var newImages: [UIImage] = []
        
        for item in selectedImages {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                newImages.append(uiImage)
            }
        }
        
        await MainActor.run {
            uploadedImages = newImages
        }
    }
    
    private func removeImage(at index: Int) {
        uploadedImages.remove(at: index)
        selectedImages.remove(at: index)
    }
    
    // MARK: - Función para enviar reporte con JSON (sin imágenes)
    
    private func createReportWithJSON(
        categoryId: Int,
        title: String,
        description: String,
        incidentDate: String,
        location: String,
        fraudContact: String,
        isAnonymous: Bool,
        token: String
    ) async throws -> Report {
        
        // Usar endpoint correcto según si es usuario registrado o invitado
        let endpoint = isGuestMode ? "/reports/guest" : "/reports"
        let url = URL(string: "http://10.48.246.68:3000\(endpoint)")!
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        httpRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Solo agregar token para usuarios autenticados (no para invitados)
        if !isGuestMode && !token.isEmpty {
            httpRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Crear el objeto JSON
        let reportData: [String: Any] = [
            "category_id": categoryId,
            "title": title,
            "description": description,
            "incident_date": incidentDate,
            "location": location,
            "fraud_contact": fraudContact,
            "is_anonymous": isAnonymous
        ]
        
        httpRequest.httpBody = try JSONSerialization.data(withJSONObject: reportData)
        
        print("📤 Enviando reporte con JSON...")
        print("🔍 Datos JSON enviados: \(reportData)")
        
        let (data, response) = try await URLSession.shared.data(for: httpRequest)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 Código de estado: \(httpResponse.statusCode)")
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Respuesta: \(jsonString)")
            }
            
            // Check if the response is successful
            if httpResponse.statusCode >= 400 {
                // Try to decode error response
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw NSError(domain: "ReportError", code: httpResponse.statusCode, 
                                userInfo: [NSLocalizedDescriptionKey: errorResponse.errorMessage])
                } else {
                    throw NSError(domain: "ReportError", code: httpResponse.statusCode, 
                                userInfo: [NSLocalizedDescriptionKey: "Error del servidor: \(httpResponse.statusCode)"])
                }
            }
        }
        
        let createdReport = try JSONDecoder().decode(Report.self, from: data)
        return createdReport
    }
    
    // MARK: - Función para enviar reporte con multipart form data
    
    private func createReportWithMultipart(
        categoryId: Int,
        title: String,
        description: String,
        incidentDate: String,
        location: String,
        fraudContact: String,
        isAnonymous: Bool,
        token: String,
        images: [Data]?
    ) async throws -> Report {
        
        // Usar endpoint correcto según si es usuario registrado o invitado
        let endpoint = isGuestMode ? "/reports/guest" : "/reports"
        let url = URL(string: "http://10.48.246.68:3000\(endpoint)")!
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        
        // Solo agregar token para usuarios autenticados (no para invitados)
        if !isGuestMode && !token.isEmpty {
            httpRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let boundary = UUID().uuidString
        httpRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Agregar campos de texto con nombres que coincidan con el servidor
        addFormField(&body, name: "category_id", value: String(categoryId), boundary: boundary)
        addFormField(&body, name: "title", value: title, boundary: boundary)
        addFormField(&body, name: "description", value: description, boundary: boundary)
        addFormField(&body, name: "incident_date", value: incidentDate, boundary: boundary)
        addFormField(&body, name: "location", value: location, boundary: boundary)
        addFormField(&body, name: "fraud_contact", value: fraudContact, boundary: boundary)
        addFormField(&body, name: "is_anonymous", value: isAnonymous ? "true" : "false", boundary: boundary)
        
        // Agregar archivos de imágenes
        if let images = images, !images.isEmpty {
            for (index, imageData) in images.enumerated() {
                addFormFile(&body, name: "files", filename: "evidence_\(index).jpg", data: imageData, boundary: boundary)
            }
        }
        
        // Cerrar boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        httpRequest.httpBody = body
        
        // Debug: Mostrar el cuerpo del multipart
        if let bodyString = String(data: body, encoding: .utf8) {
            print("📋 Cuerpo multipart:")
            print(bodyString)
        }
        
        print("📤 Enviando reporte con multipart form data...")
        print("🔍 Datos enviados:")
        print("  - category_id: \(categoryId)")
        print("  - title: '\(title)' (length: \(title.count))")
        print("  - description: '\(description)' (length: \(description.count))")
        print("  - incident_date: \(incidentDate)")
        print("  - location: \(location)")
        print("  - fraud_contact: \(fraudContact)")
        print("  - is_anonymous: \(isAnonymous)")
        
        let (data, response) = try await URLSession.shared.data(for: httpRequest)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 Código de estado: \(httpResponse.statusCode)")
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Respuesta: \(jsonString)")
            }
            
            // Check if the response is successful
            if httpResponse.statusCode >= 400 {
                // Try to decode error response
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw NSError(domain: "ReportError", code: httpResponse.statusCode, 
                                userInfo: [NSLocalizedDescriptionKey: errorResponse.errorMessage])
                } else {
                    throw NSError(domain: "ReportError", code: httpResponse.statusCode, 
                                userInfo: [NSLocalizedDescriptionKey: "Error del servidor: \(httpResponse.statusCode)"])
                }
            }
        }
        
        let createdReport = try JSONDecoder().decode(Report.self, from: data)
        return createdReport
    }
    
    private func addFormField(_ body: inout Data, name: String, value: String, boundary: String) {
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        body.append("\(value)\r\n".data(using: .utf8)!)
    }
    
    private func addFormFile(_ body: inout Data, name: String, filename: String, data: Data, boundary: String) {
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
    }
}

// MARK: - Error Response Structure (uses existing ErrorResponse from UserRegistrationDTO)

#Preview {
    NavigationStack {
        CreateReportView()
    }
}
