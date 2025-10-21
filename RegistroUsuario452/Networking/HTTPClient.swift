import Foundation

struct HTTPClient {
    func UserRegistration(name: String, email: String, password: String) async throws -> RegistrationFormResponse {
        // Crear el diccionario manualmente para asegurar el orden y formato correcto
        let requestBody: [String: Any] = [
            "email": email,
            "name": name,
            "password": password
        ]
        
        let url = URL(string: "http://192.168.0.100:3000/users")!
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        httpRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Usar JSONSerialization en lugar de Codable por si hay algún problema de encoding
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        httpRequest.httpBody = jsonData
        
        // Imprimir lo que estamos enviando
        if let requestString = String(data: jsonData, encoding: .utf8) {
            print("📤 Enviando al servidor: \(requestString)")
        }
        
        let (data, httpResponse) = try await URLSession.shared.data(for: httpRequest)
        
        // Imprimir la respuesta para debug
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Respuesta del servidor: \(responseString)")
        }
        
        // Verificar el código de estado HTTP
        if let response = httpResponse as? HTTPURLResponse {
            print("📊 Código de estado HTTP: \(response.statusCode)")
            
            if response.statusCode >= 400 {
                // Intentar decodificar el error
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw NSError(domain: "", code: response.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: errorResponse.errorMessage])
                }
                
                // Si no se puede decodificar, mostrar el mensaje raw
                if let errorString = String(data: data, encoding: .utf8) {
                    throw NSError(domain: "", code: response.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: "Error del servidor: \(errorString)"])
                }
                
                throw NSError(domain: "", code: response.statusCode,
                            userInfo: [NSLocalizedDescriptionKey: "Error al crear la cuenta. Código: \(response.statusCode)"])
            }
        }
        
        let response = try JSONDecoder().decode(RegistrationFormResponse.self, from: data)
        return response
    }
    
    func UserLogin(email: String, password: String) async throws -> LoginResponse {
        let loginRequest = LoginRequest(email: email, password: password)
        guard let url = URL(string: "http://192.168.0.100:3000/auth/login") else {
            fatalError("Invalid URL" + "http://192.168.0.100:3000/auth/login")
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try? JSONEncoder().encode(loginRequest)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        // Imprimir la respuesta para debug
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Respuesta del login: \(responseString)")
        }
        
        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        return loginResponse
    }
    
    func appleLogin(request: AppleLoginRequest) async throws -> LoginResponse {
        guard let url = URL(string: "http://192.168.0.100:3000/auth/apple/login") else {
            fatalError("Invalid URL for Apple login")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try? JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        // Imprimir la respuesta para debug
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Respuesta del Apple login: \(responseString)")
        }
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
            throw NSError(domain: "", code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "Error en login con Apple. Código: \(httpResponse.statusCode)"])
        }
        
        let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
        return loginResponse
    }
    
    func sendRequest(url: URL,
                     method: String,
                     headers: [String: String] = [:],
                     body: Data? = nil) async throws -> Data {
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30.0
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = body
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
}

extension HTTPClient {
    func get(url: URL, headers: [String: String] = [:]) async throws -> Data {
        try await sendRequest(url: url, method: "GET", headers: headers)
    }
    
    func put(url: URL, headers: [String: String] = [:], body: Data? = nil) async throws -> Data {
        try await sendRequest(url: url, method: "PUT", headers: headers, body: body)
    }
}
