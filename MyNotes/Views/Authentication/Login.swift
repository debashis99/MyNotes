//
//  Login.swift
//  MyNotes
//
//  Created by Employee on 07/05/24.
//

import Foundation
import UIKit

class Login : UIViewController {
    
    static let identifier = "Login"
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if UserManager.shared.login(username: usernameTextField.text ?? "", password: passwordTextField.text ?? "") {
            let controller = storyboard?.instantiateViewController(identifier: ListNotesViewController.identifier) as! ListNotesViewController
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let alert = UIAlertController(title: "Error", message: "Account does not exist. Please register.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
        }
    }
}
