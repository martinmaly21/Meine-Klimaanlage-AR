//
//  ProfileViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-07.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Profile"
        
        fullNameLabel.text = Auth.auth().currentUser?.displayName
        emailLabel.text = Auth.auth().currentUser?.email
        
        let logOutButton = UIBarButtonItem(
            title: "Log Out",
            style: .plain,
            target: self,
            action: #selector(didPressLogOut)
        )
        
        navigationItem.rightBarButtonItem = logOutButton
    }

    @objc func didPressLogOut() {
        let logOutAlert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you'd like to log out?",
            preferredStyle: .alert
        )
        
        let logOutAction = UIAlertAction(
            title: "Log Out",
            style: .default
        ) { action in
            do {
                try Auth.auth().signOut()
                // signed out
            } catch {
                ErrorManager.showGenericError(with: .signingOut, on: self)
            }
            
            //show initial screen
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            if let vc = storyboard.instantiateInitialViewController() {
                DispatchQueue.main.async {
                    vc.modalPresentationStyle = .overCurrentContext
                    self.tabBarController?.present(vc, animated: true, completion: nil)
                }
            }
        }
        
        logOutAlert.addAction(logOutAction)
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        logOutAlert.addAction(cancelAction)
        
        
        present(logOutAlert, animated: true, completion: nil)
    }
}
