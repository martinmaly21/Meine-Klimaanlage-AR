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
    
    private var arViewController: ARQuoteViewController? {
        guard let navBarController = presentingViewController as? UINavigationController,
              let arViewController = navBarController.topViewController as? ARQuoteViewController else {
            return nil
        }
        return arViewController
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
    }
    
    private func setUpNavBar(){
        self.title = "Choose Wire"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Choose",
            style: .done,
            target: self,
            action: #selector(didPressSave)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(didPressCancel)
        )
    }
    
    @objc func didPressSave() {
        guard let arViewController = arViewController else {
            fatalError("Could not get arViewController")
        }
        
        let acWire = ACWire(wireType: wireType, wireLocation: wireLocation)
        let wire = ARWire(wire: acWire)
        arViewController.confirmedWires.append(wire)
        
        dismiss(
            animated: true,
            completion: {
                arViewController.userChoseWire()
            }
        )
    }
    
    @objc func didPressCancel() {
        dismiss(animated: true, completion: nil)
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
