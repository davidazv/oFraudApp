//
//  ReportDetailView.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 03/10/25.
//


import SwiftUI

struct ReportDetailView: View {
    let report: Report
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Tipo de fraude - Header destacado
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tipo de Fraude")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        Text(report.displayCategoryName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.red)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.05))
                    .cornerRadius(12)
                    
                    // Título
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Título", systemImage: "text.alignleft")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        Text(report.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    
                    Divider()
                    
                    // Descripción
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Descripción", systemImage: "doc.text")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        Text(report.description)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Divider()
                    
                    // Fecha del incidente
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Fecha del Incidente", systemImage: "calendar")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        Text(report.formattedIncidentDate)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                    
                    Divider()
                    
                    // Información de contacto del fraude
                    if let fraudContact = report.fraudContact, !fraudContact.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("URL/Número/Email del Fraude", systemImage: "link")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            Text(fraudContact)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                        }
                        
                        Divider()
                    }
                    
                    // Ubicación
                    if let location = report.location, !location.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Ubicación del Incidente", systemImage: "location")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            Text(location)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                        }
                        
                        Divider()
                    }
                    
                    // Usuario
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Reportado por", systemImage: "person")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        Text(report.displayUserName)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                    
                    Divider()
                    
                    // Fecha de creación
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Fecha de Publicación", systemImage: "clock")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        Text(report.formattedCreatedDate)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                    
                    Divider()
                    
                    // Evidencia
                    if let evidenceUrl = report.evidenceUrl?.replacingOccurrences(of: "localhost", with: "192.168.0.100"), !evidenceUrl.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Evidencia", systemImage: "photo")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            AsyncImage(url: URL(string: evidenceUrl)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxHeight: 200)
                                        .cornerRadius(8)
                                        .onTapGesture {
                                            // Abrir imagen en pantalla completa si se desea
                                            if let url = URL(string: evidenceUrl) {
                                                UIApplication.shared.open(url)
                                            }
                                        }
                                case .failure(_):
                                    Rectangle()
                                        .fill(Color.red.opacity(0.1))
                                        .frame(height: 100)
                                        .cornerRadius(8)
                                        .overlay(
                                            VStack {
                                                Image(systemName: "exclamationmark.triangle")
                                                    .foregroundColor(.red)
                                                Text("Error al cargar imagen")
                                                    .font(.caption)
                                                    .foregroundColor(.red)
                                            }
                                        )
                                case .empty:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 100)
                                        .cornerRadius(8)
                                        .overlay(
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                        )
                                @unknown default:
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 100)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        Divider()
                    }
                    
                    // Estado
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Estado", systemImage: "checkmark.circle")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        HStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 10, height: 10)
                            Text(report.displayStatusName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.green)
                        }
                    }
                }
            .padding()
            .padding(.bottom, 30)
        }
        .navigationTitle("Detalle del Reporte")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.light)
    }
}

#Preview {
    ReportDetailView(report: Report(
        id: 1,
        userId: 1,
        userName: "Usuario Demo",
        categoryId: 1,
        categoryName: "Sitio Web Bancario Falso",
        statusId: 2,
        statusName: "Aceptado",
        title: "Sitio falso de Banco BBVA",
        description: "Página clonada que solicita credenciales y código OTP",
        incidentDate: "2025-09-25T06:00:00.000Z",
        location: "Ciudad de México",
        fraudContact: "https://bbva-fake.com.mx",
        evidenceUrl: nil,
        assignedAdminId: 1,
        assignedAdminName: "Carlos Martínez",
        isAnonymous: 0,
        createdAt: "2025-09-25T16:00:00.000Z",
        updatedAt: "2025-10-01T23:26:17.000Z"
    ))
}
