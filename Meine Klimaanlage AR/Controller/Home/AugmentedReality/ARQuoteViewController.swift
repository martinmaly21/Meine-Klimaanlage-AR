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
    @IBOutlet var sceneView: VirtualObjectARView!
    @IBOutlet weak var statusLabelVisualEffectView: UIVisualEffectView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusLabelCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var addUnitButton: UIButton!
    
    var coachingOverlay = ARCoachingOverlayView()
    var focusSquare = FocusSquare()
    
    //handling app state
    var appState: AppState = .lookingForSurface
    var statusMessage = ""
    var trackingStatus = ""
    
    //data that is passed in
    var quote: ACQuote!
    
    var currentACUnit: ACUnit! {
        return quote.units.last!
    }
    
    var planeDetectionType = ARWorldTrackingConfiguration.PlaneDetection.vertical
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    /// A serial queue used to coordinate adding or removing nodes from the scene.
    let updateQueue = DispatchQueue(label: "com.martinmaly.Meinde-Klimaanlage-AR")
    
    /// Coordinates the loading and unloading of reference nodes for virtual objects.
    let virtualObjectLoader = VirtualObjectLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpScene()
        setUpCoachingOverlay()
        addFocusSquare()
        setUpARSession()
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
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    private func setUpCoachingOverlay() {
        coachingOverlay = ARCoachingOverlayView(frame: .zero)
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
    
    private func addFocusSquare() {
        // Set up scene content.
        sceneView.scene.rootNode.addChildNode(focusSquare)
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
//            statusMessage = "Tap on the blue plus to place \(currentACUnit.displayName)."
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
    
    // MARK: - Focus Square

    func updateFocusSquare(isObjectVisible: Bool) {
        if isObjectVisible || coachingOverlay.isActive {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
        }
        
        // Perform ray casting only when ARKit tracking is in a good state.
        if let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
            let query = sceneView.getRaycastQuery(),
            let result = sceneView.castRay(for: query).first {
            
            updateQueue.async {
                self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(raycastResult: result, camera: camera)
            }
            if !coachingOverlay.isActive {
                addUnitButton.isHidden = false
            }
        } else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
            addUnitButton.isHidden = true
        }
    }
}

extension ARQuoteViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let isAnyObjectInView = virtualObjectLoader.loadedObjects.contains { object in
            return sceneView.isNode(object, insideFrustumOf: sceneView.pointOfView!)
        }
        
        DispatchQueue.main.async {
            self.updateFocusSquare(isObjectVisible: isAnyObjectInView)
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
    @IBAction func userPressedAddButton() {
        let center = sceneView.center
        
        guard let hitTestResult = sceneView.hitTest(center, types: [.existingPlaneUsingGeometry, .estimatedVerticalPlane]).first,
              let planeAnchor = hitTestResult.anchor as? ARPlaneAnchor,
              planeAnchor.alignment == .vertical else {
            return
        }
        
        let anchor = ARAnchor(transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: anchor)
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
