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
    @IBOutlet weak var statusLabelVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusLabelCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var addUnitButton: UIButton!
    
    //handling app state
    var appState: AppState = .lookingForSurface
    var statusMessage = ""
    var trackingStatus = ""
    
    var planeDetectionType = ARWorldTrackingConfiguration.PlaneDetection.vertical
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpScene()
        setUpCoachingOverlay()
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
        
        addUnitButton.layer.cornerRadius = 40
        addUnitButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        addUnitButton.layer.borderWidth = 1
        
        addUnitButton.layer.shadowColor = Constants.Color.border.cgColor
        addUnitButton.layer.shadowRadius = 2
        addUnitButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        addUnitButton.layer.shadowOpacity = 0.3
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 120, weight: .bold, scale: .large)
        let largeBoldDoc = UIImage(systemName: "plus.circle", withConfiguration: largeConfig)
        addUnitButton.setImage(largeBoldDoc, for: .normal)
    }
    
    private func setUpScene() {
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.preferredFramesPerSecond = 60
        sceneView.antialiasingMode = .multisampling2X
        sceneView.autoenablesDefaultLighting = true
    }
    
    private func setUpCoachingOverlay() {
        let coachingOverlay = ARCoachingOverlayView(frame: .zero)
        view.addSubview(coachingOverlay)
        
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        coachingOverlay.topAnchor.constraint(equalTo: sceneView.topAnchor).isActive = true
        coachingOverlay.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor).isActive = true
        coachingOverlay.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor).isActive = true
        coachingOverlay.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor).isActive = true
        
        coachingOverlay.goal = .verticalPlane
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.delegate = self
        coachingOverlay.session = sceneView.session
    }
    
    private func hideUIElementsForSessionStart() {
        addUnitButton.isUserInteractionEnabled = false
        
        UIView.animate(
            withDuration: 0.3) {
            self.statusLabelVisualEffectView.alpha = 0
            self.addUnitButton.alpha = 0
        }
    }
    
    private func showUIElementsForCoachingFinished() {
        addUnitButton.isUserInteractionEnabled = true
        
        UIView.animate(
            withDuration: 0.3) {
            self.statusLabelVisualEffectView.alpha = 1
            self.addUnitButton.alpha = 1
        }
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
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        //detect both horizontal and vertical planes
        configuration.planeDetection = planeDetectionType
        configuration.isLightEstimationEnabled = true
        
        return configuration
    }
    
    private func addGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //helper methods
    func updateAppState() {
        guard appState == .pointToSurface ||
                appState == .readyToAddACUnit
        else {
            return
        }
        
        if isAnyPlaneInView() {
            appState = .readyToAddACUnit
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
        case .readyToAddACUnit:
            statusMessage = "Tap on the blue plus to place unit."
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
                //                 Perform hit test for planes.
                let hitTest = sceneView.hitTest(point, types: [.existingPlaneUsingGeometry, .estimatedVerticalPlane])
                return !hitTest.isEmpty
            }
        }
        return false
    }
    
    func drawPlaneNode(on node: SCNNode, for planeAnchor: ARPlaneAnchor) {
        let planeNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        planeNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
        
        planeNode.geometry?.firstMaterial?.isDoubleSided = true
        
        planeNode.eulerAngles = SCNVector3(-Double.pi / 2, 0, 0)
        
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        
        node.addChildNode(planeNode)
        
        appState = .readyToAddACUnit
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
        //arkit hss detected a plane
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        drawPlaneNode(on: node, for: planeAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        
        drawPlaneNode(on: node, for: planeAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if anchor is ARPlaneAnchor {
            let anchorNode = SCNNode()
            anchorNode.name = "anchor"
            return anchorNode
        } else {
            
            //add unit
            let scene = SCNScene(named: "ACUnits.scnassets/Panasonic.scn")!
            #warning("Why is this calleed 'GoodSizeMaterial'?")
            let ACUnit = (scene.rootNode.childNode(withName: "GoodSizeMaterial", recursively: false))!
            ACUnit.eulerAngles = SCNVector3(CGFloat.pi * -0.5, 0.0, 0.0)
            ACUnit.scale = SCNVector3(0.5, 0.5, 0.5)
            return ACUnit
          
        }
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
    func  handleScreenTap(sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: sender.view)
        
        guard let hitTestResult = sceneView.hitTest(tapLocation, types: [.existingPlaneUsingGeometry, .estimatedVerticalPlane]).first,
              let planeAnchor = hitTestResult.anchor as? ARPlaneAnchor,
              planeAnchor.alignment == .vertical else {
            return
        }
        
        let anchor = ARAnchor(transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: anchor)
    }
    
    @IBAction func userPressedAddButton() {
        print("Add")
    }
    
    func addACUnit(hitTestResult: ARHitTestResult) {
        let transform = hitTestResult.worldTransform
        let positionColumn = transform.columns.3
        let initialPostion = SCNVector3(positionColumn.x, positionColumn.y, positionColumn.z)
        
        //add unit
        let scene = SCNScene(named: "ACUnits.scnassets/Panasonic.scn")!
        #warning("Why is this calleed 'GoodSizeMaterial'?")
        let ACUnit = (scene.rootNode.childNode(withName: "GoodSizeMaterial", recursively: false))!
        ACUnit.position = initialPostion
        ACUnit.scale = SCNVector3(0.2, 0.2, 0.2)
        sceneView.scene.rootNode.addChildNode(ACUnit)
    }
}

extension ARQuoteViewController: ARCoachingOverlayViewDelegate {
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        hideUIElementsForSessionStart()
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        showUIElementsForCoachingFinished()
    }

    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        //TODO: reset
    }
}
