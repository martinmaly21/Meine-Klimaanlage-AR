//
//  AppEntryViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-09.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit
import Firebase

class AppEntryViewController: UIViewController {
    @IBOutlet weak var loadingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openAppToCorrectStoryboard()
    }
    
    
    private func openAppToCorrectStoryboard() {
        Auth.auth().addStateDidChangeListener({ auth, user in
            let storyboard = UIStoryboard(name: user == nil ? "Onboarding" : "Root", bundle: nil)
            if let vc = storyboard.instantiateInitialViewController() {
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
            }
        })
    }
}
