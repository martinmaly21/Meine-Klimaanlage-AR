//
//  CreateAnAccountViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-07.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateAnAccountViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - Actions
    
    @IBAction func userPressedCreateAccount(_ sender: Any) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text,
            let confirmationPassword = confirmPasswordTextField.text else {
                ErrorManager.showOnboardingError(with: .missingfields, on: self)
                return
        }
        
        guard isValidEmail(email) else {
            ErrorManager.showOnboardingError(with: .invalidEmail, on: self)
            return
        }
        
        guard password == confirmationPassword else {
            ErrorManager.showOnboardingError(with: .passwordsDontMatch, on: self)
            return
        }
        
        guard isValidPassword(password) else {
            ErrorManager.showOnboardingError(with: .passwordNotStrongEnough, on: self)
            return
        }
        
        Auth.auth().createUser(
            withEmail: email,
            password: password) { (result, error) in
                if let error = error {
                    ErrorManager.showFirebaseError(with: error.localizedDescription, on: self)
                } else {
                    //user succesfully logged in
                    self.performSegue(withIdentifier: "signUpSegue", sender: self)
                }
        }
        
        
    }
    
    //MARK: - helper methods
    func isValidEmail(_ email: String) -> Bool {
        #warning("TODO: Needs to be a valid KVL email.")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        // at least one uppercase,
        // at least one digit
        // at least one lowercase
        // 8 characters total
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}")
        return passwordTest.evaluate(with: password)
    }
}
