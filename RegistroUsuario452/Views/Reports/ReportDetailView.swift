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
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Tipo de fraude - Header destacado
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tipo de Fraude")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        Text(report.categoryName)
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
                    
                    // Ubicación
                    if let location = report.location, !location.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Ubicación", systemImage: "location")
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
                        Text(report.isAnonymous == 1 ? "Usuario Anónimo" : "Usuario #\(report.userId)")
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
                    
                    // Estado
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Estado", systemImage: "checkmark.circle")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        HStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 10, height: 10)
                            Text(report.statusName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Detalle del Reporte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ReportDetailView(report: Report(
        id: 1,
        userId: 1,
        categoryId: 1,
        statusId: 2,
        title: "Sitio falso de Banco BBVA",
        description: "Página clonada que solicita credenciales y código OTP. URL similar a bbva.com.mx",
        incidentDate: "2025-09-25T06:00:00.000Z",
        location: "Ciudad de México",
        evidenceUrl: nil,
        assignedAdminId: 1,
        isAnonymous: 0,
        createdAt: "2025-09-25T16:00:00.000Z",
        updatedAt: "2025-10-01T23:26:17.000Z"
    ))
}
