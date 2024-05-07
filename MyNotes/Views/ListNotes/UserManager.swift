//
//  UserManager.swift
//  MyNotes
//
//  Created by Employee on 06/05/24.
//

import Foundation
import CryptoKit

class UserManager {
    
    static let shared = UserManager()
    
    private var token: String?
    var currentUser: User?
    
    private init() {}
    
    // Function to register a new user
    func register(username: String, password: String) -> Bool {
        // Generate token using username and password
        let token = generateToken(username: username, password: password)
        let salt = CoreDataManager.shared.generateSalt()
        do {
            let mnemonic = token
            let keySize = 32 // 256-bit key size
            let key = try CoreDataManager.shared.generateKeyFromMnemonic(mnemonic: mnemonic, salt: salt, keySize: keySize)
            let keyData = key.dataRepresentation
          //  UserDefaults.standard.set(keyData, forKey: token)
            print("Generated Key: \(key)")
            let user = CoreDataManager.shared.createUser(userName: username, key: keyData, token: token)
            self.currentUser = user
            return true
        } catch {
            self.currentUser = nil
            return false
        }
        
    }
    
    
    
    // Function to log in an existing user
    func login(username: String, password: String) -> Bool {
        let token = generateToken(username: username, password: password)
        let user = (CoreDataManager.shared.fetchUser(token: token) ?? nil)
        return authenticate(user: user)
    }
    
    // Function to generate token from username and password
    private func generateToken(username: String, password: String) -> String {
        let tokenString = username + password // Combine username and password
        return String(tokenString) // Hash the combined string to create the token
    }
    
    func authenticate(user: User?) -> Bool {
        if let savedKeyData = user?.key {
            // Key already exists in UserDefaults, retrieve and use it
            CoreDataManager.shared.key = SymmetricKey(data: savedKeyData)
            currentUser = user
            return true
        } else {
            print("Error: Username or Password does not exist")
            return false
        }
    }
}
