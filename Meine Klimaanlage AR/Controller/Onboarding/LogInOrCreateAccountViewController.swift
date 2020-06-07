//
//  ViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-07.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit

class LogInOrCreateAccountViewController: UIViewController {
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {
        //hide navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        //round corners of buttons
        signUpButton.layer.cornerRadius = signUpButton.frame.height / 2
        createAccountButton.layer.cornerRadius = createAccountButton.frame.height / 2
    }

}

