//
//  CreateAccount.swift
//  MyNotes
//
//  Created by Employee on 07/05/24.
//

import Foundation
import UIKit

class CreateAccount : UIViewController {
    
    static let identifier = "CreateAccount"
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func CreateAccoun(_ sender: UIButton) {
        if UserManager.shared.register(username: usernameTextField.text ?? "", password: passwordTextField.text ?? ""){
            let controller = storyboard?.instantiateViewController(identifier: ListNotesViewController.identifier) as! ListNotesViewController
            navigationController?.pushViewController(controller, animated: true)
        } else {
            print(false)
        }
    }
    
    
}
