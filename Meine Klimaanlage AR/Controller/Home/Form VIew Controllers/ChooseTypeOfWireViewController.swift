//
//  ChooseTypeOfWireViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-11.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit

class ChooseTypeOfWireViewController: UIViewController {
    @IBOutlet var wireTypeButtons: [UIButton]!
    @IBOutlet var wireLocationButtons: [UIButton]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Choose Wire"
    }
    
    @IBAction func didPressWireType(_ sender: UIButton) {
        for button in wireTypeButtons {
            button.backgroundColor = .clear
            button.setTitleColor(UIColor(named: "PrimaryBlue"), for: .normal)
        }
        
        sender.backgroundColor = UIColor(named: "PrimaryBlue")
        sender.setTitleColor(UIColor(named: "PrimaryTextLight"), for: .normal)
    }
    
    
    @IBAction func didPressWireLocation(_ sender: UIButton) {
        for button in wireLocationButtons {
            button.backgroundColor = .clear
            button.setTitleColor(UIColor(named: "PrimaryBlue"), for: .normal)
        }
        
        sender.backgroundColor = UIColor(named: "PrimaryBlue")
        sender.setTitleColor(UIColor(named: "PrimaryTextLight"), for: .normal)
    }
}
