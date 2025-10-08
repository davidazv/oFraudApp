//
//  ValidationSummary.swift
//  RegistroUsuario452
//
//  Created by José Molina on 22/08/25.
//

import SwiftUI

struct ValidationSummary: View {
    var errors: [String] = []
    var body: some View {
        VStack {
            if errors.isEmpty {
                Text("No hay errores")
                    .foregroundColor(.green)
            }else{
                Text("Lista de errores:")
                    .font(.headline)
                    .foregroundStyle(.red)
                ForEach(errors, id: \.self) { error in
                    Text("• \(error)")
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ValidationSummary()
}
