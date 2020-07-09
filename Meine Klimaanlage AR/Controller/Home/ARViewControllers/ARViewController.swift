//
//  ARViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-14.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit
import RealityKit
import ARKit

class ARViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var sceneView: ARSCNView!
    
    //MARK: - UI Elements
    internal let coachingOverlay = ARCoachingOverlayView()
    
    internal var focusSquare = FocusSquare()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        //setup coaching overlay
        setUpCoachingOverlay()
        
        // Set up scene content.
        sceneView.scene.rootNode.addChildNode(focusSquare)
        
        
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



extension ARViewController: ARSCNViewDelegate {
    
}

extension ARViewController: ARSessionDelegate  {
    
}
