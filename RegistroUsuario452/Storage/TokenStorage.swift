//
//  TokenStorage.swift
//  RegistroUsuario452
//
//  Created by David Antonio Zarate Villaseñor on 05/09/25.
//

import Foundation

struct TokenStorage {
    @discardableResult
    static func set(identifier: String, value: String) -> Bool {
        UserDefaults.standard.set(value, forKey: identifier)
        return true
    }
    
    static func get(identifier: String) -> String? {
        UserDefaults.standard.string(forKey: identifier)
    }
    
    /// Elimina la entrada si existe. Regresa true si había valor, false si no existía.
    @discardableResult
    static func delete(identifier: String) -> Bool {
        let existed = UserDefaults.standard.object(forKey: identifier) != nil
        if existed {
            UserDefaults.standard.removeObject(forKey: identifier)
        }
        return existed
    }
}
