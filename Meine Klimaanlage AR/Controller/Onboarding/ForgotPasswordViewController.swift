//
//  ForgotPasswordViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-07.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    @IBOutlet weak var recoveryLinkButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addGestureRecognizers()
        addNotificationObserver()
    }
    
    private func setUpUI() {
        title = "Forgot Password"
        
        recoveryLinkButton.layer.cornerRadius = recoveryLinkButton.frame.height / 2
        
        emailTextField.becomeFirstResponder()
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
    @IBAction func userPressedSendRecoveryLink(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            ErrorManager.showOnboardingError(with: .missingfields, on: self)
            return
        }
        
        Auth.auth().sendPasswordReset(
        withEmail: email) { error in
            if let error = error {
                ErrorManager.showFirebaseError(with: error.localizedDescription, on: self)
            } else {
                let successAlert = UIAlertController(title: "Success", message: "A recovery link has been sent to \(email).", preferredStyle: .alert
                )
                
                let okayAction = UIAlertAction(
                    title: "Okay",
                    style: .default,
                    handler: { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                )
                successAlert.addAction(okayAction)
                
                self.present(successAlert, animated: true, completion: nil)
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
}

