//
//  OAuth2TokenStorage.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 13.03.2024.
//
import Foundation

final class OAuth2TokenStorage {
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case token
    }
    
    // MARK: - Computed Properties
    var token: String? {
        get {
            return userDefaults.string(forKey: Keys.token.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.token.rawValue)
        }
    }
}
