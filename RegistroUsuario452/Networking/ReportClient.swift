//
//  ReportClient.swift
//  RegistroUsuario452
//

import Foundation
import UIKit

class ReportClient {
    private let baseURL = "http://10.48.246.68:3000"
    
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
    
    func createReport(token: String, report: CreateReportRequest, isGuest: Bool = false) async throws -> Report {
        // Usar /reports/guest para reportes anónimos, /reports para usuarios autenticados
        let endpoint = isGuest ? "/reports/guest" : "/reports"
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Solo agregar autorización para usuarios autenticados (no para guest)
        if !isGuest && !token.isEmpty {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(report)
        
        if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
            print("📤 Enviando reporte (\(isGuest ? "invitado" : "usuario")): \(jsonString)")
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
    
    func uploadImage(token: String, image: UIImage) async throws -> String {
        guard let url = URL(string: "\(baseURL)/files/upload") else {
            throw URLError(.badURL)
        }
        
        // Comprimir la imagen con mejor calidad y tamaño máximo
        guard let imageData = compressImage(image) else {
            throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No se pudo procesar la imagen. Verifica que sea JPG o PNG."])
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if !token.isEmpty {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Agregar imagen
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"evidence.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        print("📤 Subiendo imagen...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 Código de estado upload: \(httpResponse.statusCode)")
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Respuesta upload: \(jsonString)")
        }
        
        // Parsear respuesta con soporte para ambos formatos
        let uploadResponse = try JSONDecoder().decode(UploadResponse.self, from: data)
        return uploadResponse.url
    }
    
    private func compressImage(_ image: UIImage) -> Data? {
        // Primero redimensionar si es muy grande
        let resizedImage = resizeImage(image, maxSize: CGSize(width: 1920, height: 1920))
        
        // Intentar con JPEG a 80% de calidad primero
        if let jpegData = resizedImage.jpegData(compressionQuality: 0.8) {
            // Si es menor a 5MB, usar JPEG
            if jpegData.count < 5 * 1024 * 1024 {
                return jpegData
            }
            // Si es muy grande, reducir calidad
            if let compressedJpeg = resizedImage.jpegData(compressionQuality: 0.6) {
                return compressedJpeg
            }
        }
        
        // Fallback a PNG si JPEG falla
        return resizedImage.pngData()
    }
    
    private func resizeImage(_ image: UIImage, maxSize: CGSize) -> UIImage {
        let size = image.size
        
        // Si ya es pequeña, devolverla sin cambios
        if size.width <= maxSize.width && size.height <= maxSize.height {
            return image
        }
        
        // Calcular nueva escala manteniendo proporción
        let widthRatio = maxSize.width / size.width
        let heightRatio = maxSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        // Redimensionar
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
}

// CORRECCIÓN: Soporte para ambos formatos de respuesta del backend
struct UploadResponse: Codable {
    let message: String?
    let fileKey: String?
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case message
        case fileKey
        case url
    }
}
