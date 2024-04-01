//
//  OAuth2TokenStorage.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 13.03.2024.
//
import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    // MARK: - Private Properties
    private enum Keys: String {
        case token
    }
    
    // MARK: - Computed Properties
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: Keys.token.rawValue)
            }
        }
    }
}
