//
//  MySupportRequestsView.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 16/10/25.
//

import SwiftUI
import Foundation

struct MySupportRequestsView: View {
    @State private var supportRequests: [SupportRequest] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if isLoading {
                        Spacer()
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .red))
                            Text("Cargando mis solicitudes...")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else if let error = errorMessage {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            Text(error)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button("Reintentar") {
                                Task {
                                    await loadSupportRequests()
                                }
                            }
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        Spacer()
                    } else if supportRequests.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No tienes solicitudes de ayuda")
                                .foregroundColor(.gray)
                            Text("Cuando envíes una solicitud de ayuda, aparecerá aquí para que puedas hacer seguimiento.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(supportRequests) { request in
                                    NavigationLink(destination: SupportRequestDetailView(request: request)) {
                                        SupportRequestCard(request: request)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await loadSupportRequests()
                        }
                    }
                }
            }
            .navigationTitle("Mis Solicitudes")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadSupportRequests()
            }
        }
    }
    
    private func loadSupportRequests() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Aquí llamarías a tu API para obtener las solicitudes del usuario
            // Por ahora simulo datos
            supportRequests = await fetchMySupportRequests()
        } catch {
            errorMessage = "Error al cargar solicitudes: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func fetchMySupportRequests() async -> [SupportRequest] {
        // Obtener token del usuario
        guard let token = TokenStorage.get(identifier: "accessToken") else {
            print("No hay token disponible")
            return []
        }
        
        do {
            let url = URL(string: "http://10.48.246.68:3000/help-requests/my-requests")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 Support requests status code: \(httpResponse.statusCode)")
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 Support requests response: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let supportRequests = try decoder.decode([SupportRequest].self, from: data)
            return supportRequests
        } catch {
            print("❌ Error fetching support requests: \(error)")
            return []
        }
    }
}

struct SupportRequestCard: View {
    let request: SupportRequest
    
    var priorityColor: Color {
        switch request.priority {
        case "urgent": return .red
        case "normal": return .orange
        case "low": return .green
        default: return .gray
        }
    }
    
    var statusColor: Color {
        switch request.status {
        case "pending": return .blue
        case "in_progress": return .orange
        case "resolved": return .green
        case "closed": return .gray
        default: return .gray
        }
    }
    
    var statusText: String {
        switch request.status {
        case "pending": return "Pendiente"
        case "in_progress": return "En Progreso"
        case "resolved": return "Resuelto"
        case "closed": return "Cerrado"
        default: return request.status
        }
    }
    
    var priorityText: String {
        switch request.priority {
        case "urgent": return "Urgente"
        case "normal": return "Normal"
        case "low": return "Baja"
        default: return request.priority
        }
    }
    
    var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                // Header con título y badges
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(request.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(priorityColor)
                                    .frame(width: 6, height: 6)
                                Text(priorityText)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(priorityColor)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(priorityColor.opacity(0.1))
                            .cornerRadius(10)
                            
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(statusColor)
                                    .frame(width: 6, height: 6)
                                Text(statusText)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(statusColor)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusColor.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    
                    // Descripción truncada
                    Text(request.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 4)
                }
                
                // Respuesta del admin si existe
                if let adminResponse = request.adminResponse {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Respuesta del administrador:")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Text(adminResponse)
                            .font(.system(size: 13))
                            .foregroundColor(.blue.opacity(0.8))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(12)
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(8)
                }
                
                // Footer con fecha
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text("Creado: \(request.formattedCreatedDate)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if request.adminResponse != nil {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            Text("Respondido")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct SupportRequestDetailView: View {
    let request: SupportRequest
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Prioridad - Header destacado
                VStack(alignment: .leading, spacing: 8) {
                    Text("Prioridad de la Solicitud")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(request.priorityColor)
                        Text(request.priorityText)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(request.priorityColor)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(request.priorityColor.opacity(0.05))
                .cornerRadius(12)
                
                // Título
                VStack(alignment: .leading, spacing: 8) {
                    Label("Asunto", systemImage: "text.alignleft")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Text(request.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                Divider()
                
                // Descripción
                VStack(alignment: .leading, spacing: 8) {
                    Label("Descripción del Problema", systemImage: "doc.text")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Text(request.description)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Divider()
                
                // Estado
                VStack(alignment: .leading, spacing: 8) {
                    Label("Estado", systemImage: "checkmark.circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    HStack {
                        Circle()
                            .fill(request.statusColor)
                            .frame(width: 10, height: 10)
                        Text(request.statusText)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(request.statusColor)
                    }
                }
                
                Divider()
                
                // Respuesta del administrador (si existe)
                if let adminResponse = request.adminResponse {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Respuesta del Administrador", systemImage: "person.badge.shield.checkmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                        
                        Text(adminResponse)
                            .font(.system(size: 16))
                            .foregroundColor(.blue.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if let respondedAt = request.respondedAt {
                            HStack {
                                Image(systemName: "clock")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Text("Respondido el: \(respondedAt, style: .date)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(12)
                    
                    Divider()
                }
                
                // Fecha de creación
                VStack(alignment: .leading, spacing: 8) {
                    Label("Fecha de Creación", systemImage: "clock")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Text(request.formattedCreatedDate)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                }
                
                Divider()
                
                // ID de solicitud
                VStack(alignment: .leading, spacing: 8) {
                    Label("ID de Solicitud", systemImage: "number")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Text("#\(request.id)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .padding()
            .padding(.bottom, 30)
        }
        .navigationTitle("Detalle de Solicitud")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
    }
}

// Estructura de datos para las solicitudes de soporte
struct SupportRequest: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
    let priority: String
    let status: String
    let createdAt: Date
    let adminResponse: String?
    let respondedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case priority
        case status
        case createdAt = "created_at"
        case adminResponse = "admin_response"
        case respondedAt = "responded_at"
    }
    
    var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: createdAt)
    }
    
    var priorityColor: Color {
        switch priority {
        case "urgent": return .red
        case "normal": return .orange
        case "low": return .green
        default: return .gray
        }
    }
    
    var statusColor: Color {
        switch status {
        case "pending": return .blue
        case "in_progress": return .orange
        case "resolved": return .green
        case "closed": return .gray
        default: return .gray
        }
    }
    
    var statusText: String {
        switch status {
        case "pending": return "Pendiente"
        case "in_progress": return "En Progreso"
        case "resolved": return "Resuelto"
        case "closed": return "Cerrado"
        default: return status
        }
    }
    
    var priorityText: String {
        switch priority {
        case "urgent": return "Urgente"
        case "normal": return "Normal"
        case "low": return "Baja"
        default: return priority
        }
    }
}

#Preview {
    MySupportRequestsView()
}
