//
//  ARQuoteViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-11-21.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit
import ARKit


class ARQuoteViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    private func setUpUI() {
        view.backgroundColor = .red
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    private func setUpScene() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
                                ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.autoenablesDefaultLighting = true
        
        let scene = SCNScene(named: "ACUnits.scnassets/Panasonic.scn")!
        #warning("Why is this calleed 'GoodSizeMaterial'?")
        let ACUnit = (scene.rootNode.childNode(withName: "GoodSizeMaterial", recursively: false))!
        
        ACUnit.position = SCNVector3(0, 0, 0)
        ACUnit.scale = SCNVector3(0.2, 0.2, 0.2)
        
        sceneView.scene.rootNode.addChildNode(ACUnit)
    }
}

extension ARQuoteViewController: ARSCNViewDelegate {
    
}
