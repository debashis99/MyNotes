//
//  Register.swift
//  MyNotes
//
//  Created by Employee on 07/05/24.
//

import Foundation
import UIKit

class Register : UIViewController {
    static let identifier = "Register"
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func loginButton(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(identifier: Login.identifier) as! Login
        navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func createAccount(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(identifier: CreateAccount.identifier) as! CreateAccount
        navigationController?.pushViewController(controller, animated: true)
    }
}
