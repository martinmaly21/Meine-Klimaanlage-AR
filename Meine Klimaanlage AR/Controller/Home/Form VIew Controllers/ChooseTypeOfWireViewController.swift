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
    
    private let wireTypes: [WireType] = [.kundenname, .verkäufer, .kondensatleitung]
    private let wireLocations: [WireLocation] = [.insideWall, .outsideWall]
    
    private var wireType = WireType.kundenname
    private var wireLocation = WireLocation.insideWall
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
    }
    
    private func setUpNavBar(){
        self.title = "Choose Wire"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Choose", style: .done, target: self, action: #selector(didPressSave))
    }
    
    @objc func didPressSave() {
    
        if let arViewController = presentingViewController as? ARViewController {
            let wire = Wire(wireType: wireType, wireLocation: wireLocation)
            
            
            arViewController.quote.wires.append(wire)
          
            arViewController.instructionsLabel.text = "Tap anywhere (near the unit) to choose where first wire begins"
            arViewController.instructionsContainerView.isHidden = false
            arViewController.userIsAddingWire = true
            
            arViewController.addWireButton.setTitle("Add another wire", for: .normal)
            arViewController.saveUnitButton.isHidden = false
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func didPressWireType(_ sender: UIButton) {
        for button in wireTypeButtons {
            button.backgroundColor = .clear
            button.setTitleColor(UIColor(named: "PrimaryBlue"), for: .normal)
        }
        
        sender.backgroundColor = UIColor(named: "PrimaryBlue")
        sender.setTitleColor(UIColor(named: "PrimaryTextLight"), for: .normal)
        
        wireType = wireTypes[sender.tag]
    }
    
    @IBAction func didPressWireLocation(_ sender: UIButton) {
        for button in wireLocationButtons {
            button.backgroundColor = .clear
            button.setTitleColor(UIColor(named: "PrimaryBlue"), for: .normal)
        }
        
        sender.backgroundColor = UIColor(named: "PrimaryBlue")
        sender.setTitleColor(UIColor(named: "PrimaryTextLight"), for: .normal)
        
        wireLocation = wireLocations[sender.tag]
    }
}
