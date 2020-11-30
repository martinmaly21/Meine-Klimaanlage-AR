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
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Profile"
        
        containerView.layer.cornerRadius = 10
        containerView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        containerView.layer.borderWidth = 1
        
        containerView.layer.shadowColor = Constants.Color.border.cgColor
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        containerView.layer.shadowOpacity = 0.3
        
        fullNameLabel.text = Auth.auth().currentUser?.displayName ?? "No name provided"
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
