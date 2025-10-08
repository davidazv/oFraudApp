//
//  ReportClient.swift
//  RegistroUsuario452
//

import Foundation

class ReportClient {
    private let baseURL = "http://localhost:3000"
    
    // Reportes públicos aceptados con filtros opcionales
    func getAcceptedReports(categoryId: Int? = nil, dateFrom: String? = nil, dateTo: String? = nil) async throws -> [Report] {
        var urlString = "\(baseURL)/reports/public/accepted"
        var queryItems: [String] = []
        
        if let categoryId = categoryId {
            queryItems.append("categoryId=\(categoryId)")
        }
        if let dateFrom = dateFrom {
            queryItems.append("dateFrom=\(dateFrom)")
        }
        if let dateTo = dateTo {
            queryItems.append("dateTo=\(dateTo)")
        }
        
        if !queryItems.isEmpty {
            urlString += "?" + queryItems.joined(separator: "&")
        }
        
        print("📡 URL de reportes aceptados: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Reportes aceptados: \(jsonString)")
        }
        
        let reports = try JSONDecoder().decode([Report].self, from: data)
        return reports
    }
    
    // Reportes del usuario con filtros opcionales
    func getUserReports(token: String, statusId: Int? = nil, categoryId: Int? = nil, dateFrom: String? = nil, dateTo: String? = nil) async throws -> [Report] {
        var urlString = "\(baseURL)/reports/my-reports"
        var queryItems: [String] = []
        
        if let statusId = statusId {
            queryItems.append("statusId=\(statusId)")
        }
        if let categoryId = categoryId {
            queryItems.append("categoryId=\(categoryId)")
        }
        if let dateFrom = dateFrom {
            queryItems.append("dateFrom=\(dateFrom)")
        }
        if let dateTo = dateTo {
            queryItems.append("dateTo=\(dateTo)")
        }
        
        if !queryItems.isEmpty {
            urlString += "?" + queryItems.joined(separator: "&")
        }
        
        print("📡 URL de mis reportes: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Reportes del usuario: \(jsonString)")
        }
        
        let reports = try JSONDecoder().decode([Report].self, from: data)
        return reports
    }
    
    func createReport(token: String, report: CreateReportRequest) async throws -> Report {
        guard let url = URL(string: "\(baseURL)/reports") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(report)
        
        if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
            print("📤 Enviando reporte: \(jsonString)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 Código de estado: \(httpResponse.statusCode)")
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Respuesta: \(jsonString)")
        }
        
        let createdReport = try JSONDecoder().decode(Report.self, from: data)
        return createdReport
    }
}
