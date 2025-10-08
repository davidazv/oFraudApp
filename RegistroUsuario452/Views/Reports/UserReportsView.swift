//
//  UserReportsView.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 03/10/25.
//


import SwiftUI

struct UserReportsView: View {
    @State private var reports: [Report] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedReport: Report?
    @State private var showingDetail = false
    
    // Filtros
    @State private var selectedStatus: Int? = nil
    @State private var selectedCategory: Int? = nil
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate: Date = Date()
    @State private var showFilters = false
    @State private var applyDateFilter = false
    
    private let reportClient = ReportClient()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Botón de filtros
                    HStack {
                        Button(action: {
                            showFilters.toggle()
                        }) {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                Text("Filtros")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(20)
                        }
                        .foregroundColor(.black)
                        
                        Spacer()
                        
                        if selectedStatus != nil || selectedCategory != nil || applyDateFilter {
                            Button("Limpiar") {
                                selectedStatus = nil
                                selectedCategory = nil
                                applyDateFilter = false
                                Task {
                                    await loadReports()
                                }
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .padding()
                    
                    // Panel de filtros
                    if showFilters {
                        VStack(spacing: 12) {
                            // Filtro por estado
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Estado")
                                    .font(.system(size: 14, weight: .medium))
                                
                                HStack(spacing: 12) {
                                    FilterChip(title: "Todos", isSelected: selectedStatus == nil) {
                                        selectedStatus = nil
                                    }
                                    FilterChip(title: "Pendiente", isSelected: selectedStatus == 1) {
                                        selectedStatus = 1
                                    }
                                    FilterChip(title: "Aceptado", isSelected: selectedStatus == 2) {
                                        selectedStatus = 2
                                    }
                                    FilterChip(title: "Rechazado", isSelected: selectedStatus == 3) {
                                        selectedStatus = 3
                                    }
                                }
                            }
                            
                            // Filtro por categoría
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tipo de Fraude")
                                    .font(.system(size: 14, weight: .medium))
                                
                                Picker("Categoría", selection: $selectedCategory) {
                                    Text("Todos").tag(nil as Int?)
                                    ForEach(CategoryType.allCases) { category in
                                        Text(category.name).tag(category.id as Int?)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            // Filtro por fechas
                            VStack(alignment: .leading, spacing: 8) {
                                Toggle("Filtrar por fechas", isOn: $applyDateFilter)
                                    .font(.system(size: 14, weight: .medium))
                                
                                if applyDateFilter {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Desde")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            DatePicker("", selection: $startDate, displayedComponents: .date)
                                                .labelsHidden()
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .leading) {
                                            Text("Hasta")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            DatePicker("", selection: $endDate, displayedComponents: .date)
                                                .labelsHidden()
                                        }
                                    }
                                }
                            }
                            
                            // Botón aplicar filtros
                            Button(action: {
                                Task {
                                    await loadReports()
                                }
                            }) {
                                Text("Aplicar Filtros")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                            
                            Divider()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                    }
                    
                    if isLoading {
                        Spacer()
                        ProgressView("Cargando reportes...")
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
                                    await loadReports()
                                }
                            }
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        Spacer()
                    } else if reports.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No hay reportes")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(reports) { report in
                                    UserReportCard(report: report)
                                        .onTapGesture {
                                            selectedReport = report
                                            showingDetail = true
                                        }
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await loadReports()
                        }
                    }
                }
            }
            .navigationTitle("Mis Reportes")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await loadReports()
            }
            .sheet(isPresented: $showingDetail) {
                if let report = selectedReport {
                    ReportDetailView(report: report)
                }
            }
        }
    }
    
    private func loadReports() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let token = TokenStorage.get(identifier: "accessToken") else {
                throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No hay sesión activa"])
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let dateFrom = applyDateFilter ? dateFormatter.string(from: startDate) : nil
            let dateTo = applyDateFilter ? dateFormatter.string(from: endDate) : nil
            
            reports = try await reportClient.getUserReports(
                token: token,
                statusId: selectedStatus,
                categoryId: selectedCategory,
                dateFrom: dateFrom,
                dateTo: dateTo
            )
        } catch {
            errorMessage = "Error al cargar reportes: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

struct UserReportCard: View {
    let report: Report
    
    var statusColor: Color {
        switch report.statusId {
        case 1: return .yellow
        case 2: return .green
        case 3: return .red
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header con tipo y estado
            HStack {
                Text(report.categoryName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    Text(report.statusName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(statusColor.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Título
            Text(report.title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.gray)
                .lineLimit(2)
            
            // Descripción truncada
            Text(report.description)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineLimit(2)
            
            // Footer con fecha
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 12))
                Text(report.formattedCreatedDate)
                    .font(.system(size: 12))
                
                Spacer()
                
                Text("Ver detalles")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.red)
            }
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.red : Color.gray.opacity(0.1))
                .cornerRadius(16)
        }
    }
}

#Preview {
    UserReportsView()
}
