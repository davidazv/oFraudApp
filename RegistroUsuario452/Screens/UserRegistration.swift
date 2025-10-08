import SwiftUI

struct UserRegistration: View {
    @Environment(\.authController) var authetnticationController
    @State var registrationForm = UserRegistrationForm()
    @State var errorMessages: [String] = []
    func register() async{
        do{
            let response = try await authetnticationController.registerUser(name: registrationForm.nombre, email: registrationForm.correo, password: registrationForm.contraseña)
            print("Usuario registrado: \(response)")
        }
        catch{
            print("Error al registrarte: \(error)")
        }
    }
    var body: some View {
        VStack {
            Text("Registro")
                .font(.title)
            
            Form{
                TextField("Nombre", text: $registrationForm.nombre)
                TextField("Correo", text: $registrationForm.correo)
                SecureField("Contraseña", text: $registrationForm.contraseña)
                Button("Registrar"){
                    errorMessages = registrationForm.validate()
                    if errorMessages.isEmpty{
                        Task{
                            await register()
                        }
                    }
                }
            }
            if !errorMessages.isEmpty{
                ValidationSummary(errors: errorMessages)
            }
            
        }
        
    }
    
    
}

extension UserRegistration{
    struct UserRegistrationForm{
        var nombre: String = ""
        var correo: String = ""
        var contraseña: String = ""
        func validate() -> [String] {
            var errors: [String] = []
            if nombre.esVacio{
                errors.append("El nombre es requerido")
            }
            if correo.esVacio{
                errors.append("El correo es requerido")
            }
            if contraseña.esVacio{
                errors.append("La contraseña es requerida")
            }
            if !correo.esCorreoValido{
                errors.append("El correo no es valido")
            }
            if !contraseña.esPasswordValido{
                errors.append("La contraseña no cumple con el requerimiento de 3 caracteres")
            }
            return errors
            
        }
    }
}

#Preview {
    UserRegistration()
}
