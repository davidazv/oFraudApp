//
//  AcceptedReportsView.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 03/10/25.
//


import SwiftUI

struct AcceptedReportsView: View {
    @State private var reports: [Report] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Filtros
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
                        
                        if selectedCategory != nil || applyDateFilter {
                            Button("Limpiar") {
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
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No hay reportes aceptados")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(reports) { report in
                                    NavigationLink(destination: ReportDetailView(report: report)) {
                                        ReportCard(report: report)
                                    }
                                    .buttonStyle(PlainButtonStyle())
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
            .navigationTitle("Reportes")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadReports()
            }
            .preferredColorScheme(.light)
        }
    }
    
    private func loadReports() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let dateFrom = applyDateFilter ? dateFormatter.string(from: startDate) : nil
            let dateTo = applyDateFilter ? dateFormatter.string(from: endDate) : nil
            
            reports = try await reportClient.getAcceptedReports(
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

struct ReportCard: View {
    let report: Report
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tipo de fraude
            Text(report.displayCategoryName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            // Título
            Text(report.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .lineLimit(2)
            
            // Descripción truncada
            Text(report.description)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineLimit(3)
            
            Divider()
            
            HStack {
                // Fecha
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                    Text(report.formattedCreatedDate)
                        .font(.system(size: 12))
                }
                .foregroundColor(.gray)
                
                Spacer()
                
                // Botón ver detalles
                Text("Ver detalles")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    AcceptedReportsView()
}
