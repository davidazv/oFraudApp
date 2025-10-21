//
//  TermsAndPrivacyView.swift
//  RegistroUsuario452
//
//  Created by Claude Code on 13/10/25.
//

import SwiftUI
import WebKit

struct TermsAndPrivacyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            WebView(fileName: "terminos_privacidad")
                .navigationTitle("Términos de Privacidad")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cerrar") {
                            dismiss()
                        }
                        .foregroundColor(.gray)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ShareLink(item: getHTMLContent()) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
        }
    }
    
    private func getHTMLContent() -> String {
        guard let path = Bundle.main.path(forResource: "terminos_privacidad", ofType: "html"),
              let content = try? String(contentsOfFile: path) else {
            return "No se pudo cargar el contenido"
        }
        return content
    }
}

struct WebView: UIViewRepresentable {
    let fileName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        loadLocalHTML(webView: webView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private func loadLocalHTML(webView: WKWebView) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "html") else {
            // Si no se encuentra el archivo, mostrar contenido de respaldo
            let fallbackHTML = """
            <!DOCTYPE html>
            <html lang="es">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Términos de Privacidad</title>
                <style>
                    body { 
                        font-family: -apple-system, BlinkMacSystemFont, sans-serif; 
                        padding: 20px; 
                        line-height: 1.6;
                        color: #333;
                    }
                    h1 { color: #dc3545; text-align: center; }
                    .error { 
                        background: #f8d7da; 
                        border: 1px solid #f5c6cb; 
                        color: #721c24; 
                        padding: 15px; 
                        border-radius: 5px; 
                        margin: 20px 0;
                    }
                </style>
            </head>
            <body>
                <h1>Términos de Privacidad - oFRAUD</h1>
                <div class="error">
                    <strong>Error:</strong> No se pudo cargar el archivo de términos de privacidad.
                </div>
                <p>Por favor, contacta al soporte técnico para obtener información sobre nuestros términos de privacidad.</p>
                <p><strong>Email:</strong> soporte@ofraud.com</p>
            </body>
            </html>
            """
            webView.loadHTMLString(fallbackHTML, baseURL: nil)
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Permitir la navegación local, pero abrir enlaces externos en Safari
            if let url = navigationAction.request.url {
                if url.scheme == "file" {
                    decisionHandler(.allow)
                } else if url.scheme == "http" || url.scheme == "https" {
                    UIApplication.shared.open(url)
                    decisionHandler(.cancel)
                } else {
                    decisionHandler(.allow)
                }
            } else {
                decisionHandler(.allow)
            }
        }
    }
}

#Preview {
    TermsAndPrivacyView()
}