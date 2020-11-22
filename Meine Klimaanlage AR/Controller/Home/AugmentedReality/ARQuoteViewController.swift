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
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusLabelCenterYConstraint: NSLayoutConstraint!
    
    //handling app state
    var appState: AppState = .lookingForSurface
    var statusMessage = ""
    var trackingStatus = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpScene()
        setUpARSession()
        addGestureRecognizers()
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
        
        
        if let topSafeAreaInset = UIApplication.shared.windows.first?.safeAreaInsets.top {
            statusLabelHeightConstraint.constant += topSafeAreaInset
            statusLabelCenterYConstraint.constant = topSafeAreaInset / 2
        }
    }
    
    private func setUpScene() {
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.preferredFramesPerSecond = 60
        sceneView.antialiasingMode = .multisampling2X
        sceneView.autoenablesDefaultLighting = true
        
        //        let scene = SCNScene(named: "ACUnits.scnassets/Panasonic.scn")!
        //        #warning("Why is this calleed 'GoodSizeMaterial'?")
        //        let ACUnit = (scene.rootNode.childNode(withName: "GoodSizeMaterial", recursively: false))!
        //
        //        ACUnit.position = SCNVector3(0, 0, 0)
        //        ACUnit.scale = SCNVector3(0.2, 0.2, 0.2)
        //
        //        sceneView.scene.rootNode.addChildNode(ACUnit)
    }
    
    private func setUpARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            ErrorManager.showGenericError(with: .ARNotSupported, on: self)
            return
        }
        
        // Create a session configuration
        let configuration = createConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    private func createConfiguration() -> ARWorldTrackingConfiguration {
        return ARWorldTrackingConfiguration()
    }
    
    private func addGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //helper methods
    func updateAppState() {
        guard appState == .pointToSurface ||
                appState == .readyToFurnish
        else {
            return
        }
        
        if isAnyPlaneInView() {
            appState = .readyToFurnish
        } else {
            appState = .pointToSurface
        }
    }
    
    // Updates the status text displayed at the top of the screen.
    func updateStatusText() {
        switch appState {
        case .lookingForSurface:
            statusMessage = "Scan the room with your device until the yellow dots appear."
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        case .pointToSurface:
            statusMessage = "Point your device towards one of the detected surfaces."
            sceneView.debugOptions = []
        case .readyToFurnish:
            statusMessage = "Tap on the floor grid to place furniture; look at walls to place posters."
            sceneView.debugOptions = []
        }
        
        statusLabel.text = trackingStatus != "" ? "\(trackingStatus)" : "\(statusMessage)"
    }
    
    // We can’t check *every* point in the view to see if it contains one of
    // the detected planes. Instead, we assume that the planes that will be detected
    // will intersect with at least one point on a 5*5 grid spanning the entire view.
    func isAnyPlaneInView() -> Bool {
        let screenDivisions = 5 - 1
        let viewWidth = view.bounds.size.width
        let viewHeight = view.bounds.size.height
        
        for y in 0...screenDivisions {
            let yCoord = CGFloat(y) / CGFloat(screenDivisions) * viewHeight
            for x in 0...screenDivisions {
                let xCoord = CGFloat(x) / CGFloat(screenDivisions) * viewWidth
                let point = CGPoint(x: xCoord, y: yCoord)
                
                // Perform hit test for planes.
                
                
            }
        }
        return false
    }
}

extension ARQuoteViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateAppState()
            self.updateStatusText()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        //
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        //
    }
    
    // MARK: - AR session error management
    // ===================================
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        trackingStatus = "AR session failure: \(error)"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        trackingStatus = "AR session was interrupted!"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        trackingStatus = "AR session interruption ended."
        #warning("reset AR?")
        //resetARsession()
    }
}

//MARK: - adding and removing ac units
extension ARQuoteViewController {
    @objc
    func  handleScreenTap() {
        
    }
    
    func addACUnit(hitTestResult: ARHitTestResult) {
        
        
    }
}

#warning("do we need this??")
extension ARQuoteViewController {
    // MARK: - Utility methods
    // =======================
    
//    // Extend the "+" operator so that it can add two SCNVector3s together.
//    func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
//        return SCNVector3(left.x + right.x,
//                          left.y + right.y,
//                          left.z + right.z)
//    }
    
}
