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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addGestureRecognizers()
        addNotificationObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setUpUI() {
        createAccountButton.layer.cornerRadius = createAccountButton.frame.height / 2
        
        nameTextField.becomeFirstResponder()
    }
    
    private func addGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScreen))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func addNotificationObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    //MARK: - Actions
    @IBAction func userPressedCreateAccount(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty,
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty,
            let confirmationPassword = confirmPasswordTextField.text, !confirmationPassword.isEmpty else {
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
            password: password
        ) { (result, error) in
            guard error == nil, let user = result?.user else {
                ErrorManager.showFirebaseError(with: error?.localizedDescription ?? "", on: self)
                return
            }
            self.updateUserName(with: user, with: name)
        }
    }
    
    private func updateUserName(with user: User, with name: String) {
        let profileChangeRequest = user.createProfileChangeRequest()
        profileChangeRequest.displayName = name
        
        profileChangeRequest.commitChanges { error in
            if let error = error {
                ErrorManager.showFirebaseError(with: error.localizedDescription, on: self)
            } else {
                //user succesfully logged in
                self.performSegue(withIdentifier: "signUpSegue", sender: self)
            }
        }
    }
    
    @objc func didTapScreen() {
        view.endEditing(true)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
            scrollView.scrollIndicatorInsets = .zero
        } else {
            let inset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
            scrollView.contentInset = inset
            scrollView.scrollIndicatorInsets = inset
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
