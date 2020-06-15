//
//  ARViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-14.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit
import RealityKit

class ARViewController: UIViewController {
    @IBOutlet weak var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        guard let anchor = try? ETHEREAWandgerätBaureiheZScene.loadScene() else {
            assertionFailure()
            return
        }
        arView.scene.anchors.append(anchor)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    
    private func setUpUI() {
        tabBarController?.tabBar.isHidden = true
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: nil)
        saveButton.isEnabled = false
        navigationItem.rightBarButtonItem = saveButton
    }
    
}
