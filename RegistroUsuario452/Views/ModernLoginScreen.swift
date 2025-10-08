//
//  ModernLoginScreen.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 30/09/25.
//
import SwiftUI

struct ModernLoginScreen: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @Environment(\.authController) var authenticationController
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var showRegistration = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    private func login() async {
        isLoading = true
        do {
            isLoggedIn = try await authenticationController.loginUser(email: email, password: password)
            print("Usuario login exitoso \(isLoggedIn)")
        } catch {
            errorMessage = "Usuario o contraseña incorrectos. Por favor, verifica tus datos."
            showingErrorAlert = true
            print(error.localizedDescription)
        }
        isLoading = false
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
                        TextField("correoelectrónico@dominio.com", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textContentType(.username)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal, 32)
                        
                        SecureField("contraseña", text: $password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .textContentType(.password)
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
                            // Acción para continuar como invitado
                            print("Continuar como invitado - funcionalidad por implementar")
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
                    
                    // Botones de redes sociales
                    VStack(spacing: 12) {
                        Button(action: {
                            // Acción Google
                            print("Continuar con Google - funcionalidad por implementar")
                        }) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                    .foregroundColor(.red)
                                Text("Continuar con Google")
                                    .foregroundColor(.black)
                            }
                            .font(.system(size: 16, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 32)
                        
                        Button(action: {
                            // Acción Apple
                            print("Continuar con Apple - funcionalidad por implementar")
                        }) {
                            HStack {
                                Image(systemName: "apple.logo")
                                    .foregroundColor(.black)
                                Text("Continuar con Apple")
                                    .foregroundColor(.black)
                            }
                            .font(.system(size: 16, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 24)
                    
                    // Términos y condiciones
                    Text("Al hacer clic en continuar, aceptas nuestros **Términos de servicio** y **Política de privacidad**")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
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
        }
    }
}

#Preview {
    ModernLoginScreen()
}
