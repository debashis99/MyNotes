//
//  CoreDataManager.swift
//  MyNotes
//
//  Created by Employee on 06/05/24.
//

import Foundation
import CoreData
import CryptoKit
import CommonCrypto
import UIKit

class CoreDataManager {
    
    static let shared = CoreDataManager(modelName: "MyNotes")
    var key: SymmetricKey!
    
    let persistenContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistenContainer.viewContext
    }
    
    init( modelName: String) {
        persistenContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion : (() -> Void)? = nil) {
        persistenContainer.loadPersistentStores {
            (description, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
    // Set encryption key derived from mnemonic phrase
    func setEncryptionKey(from mnemonicPhrase: String) {
        key = SymmetricKey(data: Data(mnemonicPhrase.utf8))
        print(key)
    }
    

    func generateKeyFromMnemonic(mnemonic: String, salt: Data, keySize: Int) throws -> SymmetricKey {
        // Convert mnemonic phrase to Data
        guard let mnemonicData = mnemonic.data(using: .utf8) else {
            throw KeyGenerationError.invalidMnemonic
        }
        
        // Initialize derived key buffer
        var derivedKey = Data(repeating: 0, count: keySize)
        
        // Perform key derivation
        let status = derivedKey.withUnsafeMutableBytes { derivedKeyBytes in
            salt.withUnsafeBytes { saltBytes in
                mnemonicData.withUnsafeBytes { mnemonicBytes in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        mnemonicBytes.baseAddress!.assumingMemoryBound(to: Int8.self),
                        mnemonicData.count,
                        saltBytes.baseAddress!.assumingMemoryBound(to: UInt8.self),
                        salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        10000, // Number of iterations
                        derivedKeyBytes.bindMemory(to: UInt8.self).baseAddress,
                        keySize
                    )
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw KeyGenerationError.keyDerivationFailed
        }
        
        // Create SymmetricKey from derived key
        key = SymmetricKey(data: derivedKey)
        return key
    }

    
    func generateSalt() -> Data {
        var randomBytes = [UInt8](repeating: 0, count: 16) // 16 bytes for a typical salt
        _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        return Data(randomBytes)
    }
    
    
    
    // Generate key from mnemonic phrase
    enum KeyGenerationError: Error {
        case invalidMnemonic
        case keyDerivationFailed
    }

    
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("An error occured while saving: \(error.localizedDescription)")
            }
        }
    }
}

// MARK:- Helper Function
extension CoreDataManager {
    // Encrypt text using the configured key
    func encrypt(_ text: String) throws -> String {
        guard let plainData = text.data(using: .utf8), !plainData.isEmpty else {
           return ""
        }
        
        let sealedBox = try AES.GCM.seal(plainData, using: key)
        return sealedBox.combined!.base64EncodedString()
    }


        // Decrypt text using the configured key
    func decrypt(_ data: String) throws -> String {
        guard let decodedData = Data(base64Encoded: data) else {
            throw DecryptionError.invalidBase64
        }
        
        let sealedBox = try AES.GCM.SealedBox(combined: decodedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return String(decoding: decryptedData, as: UTF8.self)
    }
    enum DecryptionError: Error {
        case invalidBase64
    }

    func createNote() -> Note {
        let note = Note(context: viewContext)
        note.userId = UserManager.shared.currentUser?.token
        note.id = UUID()
        note.lastUpdated = Date()
        note.text = ""
        
        do {
            note.text = try encrypt(note.text)
        } catch {
            // Handle encryption error gracefully
            print("Encryption error: \(error)")
            // Optionally, set a default or empty encrypted text
            note.text = ""
        }
        
        save()
        return note
    }
    
    func createUser(userName: String, key: Data, token: String) -> User {
        let user = User(context: viewContext)
        user.userId =  UIDevice.current.identifierForVendor?.uuidString ?? ""
        user.userName = userName
        user.key = key
        user.token = token
        save()
        return user
    }
    
    func fetchNotes(filter: String? = nil) -> [Note] {
        guard let currentUserToken = UserManager.shared.currentUser?.token else {
                return []
        }
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \Note.lastUpdated, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        if let filter = filter {
            let predicate = NSPredicate(format: "text contains[cd] %@", filter)
            request.predicate = predicate
        }
        
        let currentUserPredicate = NSPredicate(format: "userId == %@", currentUserToken)
        if let existingPredicate = request.predicate {
                // Combine existing predicate with currentUserPredicate using AND
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existingPredicate, currentUserPredicate])
            } else {
                // If there's no existing predicate, set currentUserPredicate directly
                request.predicate = currentUserPredicate
        }
        var notes = (try? viewContext.fetch(request)) ?? []
        for note in notes {
            let encryptedText = note.text
            let decryptedText: String
            do {
                decryptedText = try decrypt(encryptedText ?? "")
            } catch {
                decryptedText = encryptedText ?? ""
            }
            note.text = decryptedText
        }
        return notes
    }
    
    func fetchUser(token: String? = nil) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        if let token = token {
            let predicate = NSPredicate(format: "token == %@", token)
            request.predicate = predicate
        }
        
        do {
            let users = try viewContext.fetch(request)
            return users.first // Return the first user found (or nil if not found)
        } catch {
            print("Error fetching user: \(error)")
            return nil
        }
    }


    
    func  deleteNote(_ note: Note){
        viewContext.delete(note)
        save()
    }
}
