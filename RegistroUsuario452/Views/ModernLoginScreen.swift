//
//  ModernLoginScreen.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 30/09/25.
//

import SwiftUI
import AuthenticationServices

struct ModernLoginScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @Environment(\.authController) var authenticationController
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("isGuestMode") var isGuestMode: Bool = false
    @State private var showRegistration = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showTermsAndPrivacy = false
    
    private func login() async {
        isLoading = true
        do {
            isLoggedIn = try await authenticationController.loginUser(email: email, password: password)
            isGuestMode = false // Asegurar que no está en modo invitado
            print("Usuario login exitoso \(isLoggedIn)")
        } catch {
            errorMessage = "Usuario o contraseña incorrectos. Por favor, verifica tus datos."
            showingErrorAlert = true
            print(error.localizedDescription)
        }
        isLoading = false
    }
    
    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                print("✅ Apple Sign In exitoso")
                print("User ID: \(appleIDCredential.user)")
                
                // Obtener datos del usuario
                let userIdentifier = appleIDCredential.user
                var userName = "Usuario Apple"
                var userEmail = "\(userIdentifier)@privaterelay.appleid.com"
                
                // Apple solo proporciona email y nombre la PRIMERA vez
                if let email = appleIDCredential.email, !email.isEmpty {
                    userEmail = email
                    print("📧 Email: \(email)")
                }
                
                if let fullName = appleIDCredential.fullName {
                    if let givenName = fullName.givenName, let familyName = fullName.familyName {
                        userName = "\(givenName) \(familyName)"
                    } else if let givenName = fullName.givenName {
                        userName = givenName
                    }
                    print("👤 Nombre: \(userName)")
                }
                
                // Implementar el login real con Apple
                Task {
                    do {
                        // Obtener token de identidad
                        guard let identityTokenData = appleIDCredential.identityToken,
                              let identityTokenString = String(data: identityTokenData, encoding: .utf8) else {
                            throw NSError(domain: "AppleError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No se pudo obtener el token de identidad"])
                        }
                        
                        // Llamar al backend real
                        let success = try await authenticationController.loginWithApple(
                            appleUserId: userIdentifier,
                            email: userEmail,
                            name: userName,
                            identityToken: identityTokenString
                        )
                        
                        await MainActor.run {
                            if success {
                                // Guardar información temporal para referencia
                                UserDefaults.standard.set(userName, forKey: "tempAppleName")
                                UserDefaults.standard.set(userEmail, forKey: "tempAppleEmail")
                                UserDefaults.standard.set(userIdentifier, forKey: "appleUserId")
                                
                                isLoggedIn = true
                                isGuestMode = false
                                
                                print("✅ Login con Apple exitoso")
                            } else {
                                errorMessage = "Error al autenticar con Apple"
                                showingErrorAlert = true
                            }
                        }
                    } catch {
                        await MainActor.run {
                            errorMessage = "Error al procesar Apple Sign-In: \(error.localizedDescription)"
                            showingErrorAlert = true
                        }
                    }
                }
            }
        case .failure(let error):
            let nsError = error as NSError
            print("❌ Error en Apple Sign In - Code: \(nsError.code)")
            
            // Solo mostrar error si NO es cancelación del usuario
            guard nsError.code != ASAuthorizationError.canceled.rawValue else {
                print("ℹ️ Usuario canceló el Apple Sign In")
                return
            }
            
            // Manejar otros errores específicos
            switch nsError.code {
            case ASAuthorizationError.unknown.rawValue:
                errorMessage = "Apple Sign-In no está disponible en este momento. Intenta usar email y contraseña."
            case ASAuthorizationError.invalidResponse.rawValue:
                errorMessage = "Error de comunicación con Apple. Verifica tu conexión a internet."
            case ASAuthorizationError.notHandled.rawValue:
                errorMessage = "Apple Sign-In no está configurado correctamente."
            case ASAuthorizationError.failed.rawValue:
                errorMessage = "Apple Sign-In falló. Verifica tu configuración de Apple ID."
            case 1000:
                errorMessage = "Apple Sign-In temporalmente no disponible. Usa email y contraseña."
            default:
                errorMessage = "Error \(nsError.code) con Apple Sign-In. Usa email y contraseña para continuar."
            }
            showingErrorAlert = true
        }
    }
    
    
    private func activateGuestMode() {
        isGuestMode = true
        isLoggedIn = true
        print("✅ Modo invitado activado")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header con botón Crear cuenta
                    HStack {
                        Spacer()
                        NavigationLink(destination: ModernRegistrationScreen()) {
                            Text("Crear cuenta")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }
                    
                    // Logo oFraud
                    Text("oFraud")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.red)
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    // Título y subtítulo
                    VStack(spacing: 8) {
                        Text("LogIn")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text("Ingresa tu correo electrónico\npara registrarte en esta aplicación")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 40)
                    
                    // Campos de entrada
                    VStack(spacing: 16) {
                        TextField("Correo electrónico", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textContentType(.username)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 32)
                        
                        SecureField("contraseña", text: $password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textContentType(.password)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 24)
                    
                    // Botones principales
                    VStack(spacing: 12) {
                        Button(action: {
                            Task {
                                await login()
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            } else {
                                Text("Continuar")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                        }
                        .background(Color.black)
                        .cornerRadius(12)
                        .disabled(isLoading)
                        .padding(.horizontal, 32)
                        
                        Button(action: {
                            activateGuestMode()
                        }) {
                            Text("Continuar como invitado")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.black)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 20)
                    
                    // Separador
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        
                        Text("o")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 12)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 20)
                    
                    // Botón de Apple Sign-In
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: handleAppleSignIn
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                    
                    // Términos y condiciones
                    VStack(spacing: 4) {
                        Text("Al hacer clic en continuar, aceptas nuestros")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Button("**Términos de servicio** y **Política de privacidad**") {
                            showTermsAndPrivacy = true
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
            .alert("Error de inicio de sesión", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .sheet(isPresented: $showTermsAndPrivacy) {
                TermsAndPrivacyView()
            }
            .preferredColorScheme(.light)
        }
    }
}

#Preview {
    ModernLoginScreen()
}
