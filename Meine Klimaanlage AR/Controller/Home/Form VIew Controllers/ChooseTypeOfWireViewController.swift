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
    
    private let wireTypes: [WireType] = [.rohrleitungslänge, .kabelkanal, .kondensatleitung]
    private let wireLocations: [WireLocation] = [.insideWall, .outsideWall]
    
    private var wireType = WireType.rohrleitungslänge
    private var wireLocation = WireLocation.insideWall
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
    }
    
    private func setUpNavBar(){
        self.title = "Choose Wire"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Choose", style: .done, target: self, action: #selector(didPressSave))
    }
    
    @objc func didPressSave() {
        if let arViewController = presentingViewController as? ARQuoteViewController {
            let wire = ACWire(wireType: wireType, wireLocation: wireLocation)
            
            #warning("must uncomment now")
//            arViewController.quote.wires.append(wire)
            
            arViewController.appState = .addingWire

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
