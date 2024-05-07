//
//  AppDelegate.swift
//  MyNotes
//
//  Created by Employee on 06/05/24.
//

import UIKit
import CryptoKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //let userManager = UserManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CoreDataManager.shared.load {
            //  let mnemonicPhrase = UserManager.currentUser?.mnemonicPhrase {
            if let savedKeyData = UserDefaults.standard.data(forKey: "encryptionKey") {
                // Key already exists in UserDefaults, retrieve and use it
                CoreDataManager.shared.key = SymmetricKey(data: savedKeyData)
            } else {
                let salt = CoreDataManager.shared.generateSalt()
                do {
                    let mnemonic = "mnemonicPhrase"
                    let keySize = 32 // 256-bit key size
                    let key = try CoreDataManager.shared.generateKeyFromMnemonic(mnemonic: mnemonic, salt: salt, keySize: keySize)
                    let keyData = key.dataRepresentation
                    UserDefaults.standard.set(keyData, forKey: "encryptionKey")
                    print("Generated Key: \(key)")
                } catch {
                    print("Error generating key: \(error)")
                }
                
                // CoreDataManager.shared.setEncryptionKey(from: "mnemonicPhrase")
                // }
            }
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveAllChanges()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveAllChanges()
    }

    private func saveAllChanges() {
        // TODO Save all changes
        
    }
}

extension SymmetricKey {
    var dataRepresentation: Data {
        return withUnsafeBytes { Data($0) }
    }
}

