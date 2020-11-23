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
    
    //    var currentACUnit: ACUnit! {
    //        return quote.units.last!
    //    }
    var currentACUnit: ACUnit!
    
    var planeDetectionType = ARWorldTrackingConfiguration.PlaneDetection.vertical
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    /// A serial queue used to coordinate adding or removing nodes from the scene.
    let updateQueue = DispatchQueue(label: "com.martinmaly.Meinde-Klimaanlage-AR")
    
    /// Coordinates the loading and unloading of reference nodes for virtual objects.
    let virtualObjectLoader = VirtualObjectLoader()
    
    //    /// A type which manages gesture manipulation of virtual content in the scene.
    lazy var virtualObjectInteraction = VirtualObjectInteraction(sceneView: sceneView, viewController: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentACUnit = ACUnit(displayName: "Panasonic", fileName: "Panasonic")
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
        
        if focusSquare.state == .initializing {
            appState = .pointToSurface
        } else {
            appState = .readyToAddACUnit
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
            statusMessage = "Tap on the blue plus to place \(currentACUnit.displayName)."
            sceneView.debugOptions = []
        case .ACUnitBeingAdded:
            statusMessage = "\(currentACUnit.displayName) is loading. Please wait."
        case .ACUnitAdded:
            statusMessage = "\(currentACUnit.displayName) added! You can drag/rotate the unit to reposition it."
        }
        
        statusLabel.text = trackingStatus != "" ? "\(trackingStatus)" : "\(statusMessage)"
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
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        updateQueue.async {
            if let objectAtAnchor = self.virtualObjectLoader.loadedObjects.first(where: { $0.anchor == anchor }) {
                objectAtAnchor.simdPosition = anchor.transform.translation
                objectAtAnchor.anchor = anchor
            }
        }
    }
    
    // MARK: - AR session error management
    // ===================================
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable, .limited:
            #warning("TODO: update sttate")
//            statusViewController.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
        case .normal:
            #warning("TODO: update sttate")
//            statusViewController.cancelScheduledMessage(for: .trackingStateEscalation)
//            showVirtualContent()
        }
    }
    
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
        // Ensure adding objects is an available action and we are not loading another object (to avoid concurrent modifications of the scene).
        //do we need this?
        guard !virtualObjectLoader.isLoading else { return }
        
        if let filePath = Bundle.main.path(forResource: currentACUnit.fileName, ofType: "scn", inDirectory: "ACUnits.scnassets") {
            let referenceURL = URL(fileURLWithPath: filePath)
            let virtualObject = VirtualObject(url: referenceURL)!
            
            #warning("TODO: this alignment will need to be changed")
            if let query = sceneView.getRaycastQuery(for: .vertical),
               let result = sceneView.castRay(for: query).first {
                virtualObject.mostRecentInitialPlacementResult = result
                virtualObject.raycastQuery = query
            }
            
            virtualObjectLoader.loadVirtualObject(virtualObject, loadedHandler: { [unowned self] loadedObject in
                do {
                    let scene = try SCNScene(
                        url: virtualObject.referenceURL,
                        options: nil
                    )
                    self.sceneView.prepare(
                        [scene],
                        completionHandler: { _ in
                            DispatchQueue.main.async {
                                self.appState = .ACUnitAdded
                                self.placeVirtualObject(loadedObject)
                            }
                        }
                    )
                } catch {
                    fatalError("Failed to load SCNScene from object.referenceURL")
                }
                
            }
            )
            appState = .ACUnitBeingAdded
        }
    }
    
    /** Adds the specified virtual object to the scene, placed at the world-space position
     estimated by a hit test from the center of the screen.
     - Tag: PlaceVirtualObject */
    func placeVirtualObject(_ virtualObject: VirtualObject) {
        guard focusSquare.state != .initializing, let query = virtualObject.raycastQuery else {
            return
        }
        
        let trackedRaycast = createTrackedRaycastAndSet3DPosition(
            of: virtualObject,
            from: query,
            withInitialResult: virtualObject.mostRecentInitialPlacementResult
        )
        
        virtualObject.raycast = trackedRaycast
        virtualObjectInteraction.selectedObject = virtualObject
        virtualObject.isHidden = false
    }
    
    // - Tag: GetTrackedRaycast
    func createTrackedRaycastAndSet3DPosition(
        of virtualObject: VirtualObject,
        from query: ARRaycastQuery,
        withInitialResult initialResult: ARRaycastResult? = nil
    ) -> ARTrackedRaycast? {
        if let initialResult = initialResult {
            self.setTransform(of: virtualObject, with: initialResult)
        }
        
        return session.trackedRaycast(query) { (results) in
            self.setVirtualObject3DPosition(results, with: virtualObject)
        }
    }
    
    func createRaycastAndUpdate3DPosition(of virtualObject: VirtualObject, from query: ARRaycastQuery) {
        guard let result = session.raycast(query).first else {
            return
        }
        
        if virtualObject.allowedAlignment == .any && self.virtualObjectInteraction.trackedObject == virtualObject {
            
            // If an object that's aligned to a surface is being dragged, then
            // smoothen its orientation to avoid visible jumps, and apply only the translation directly.
            virtualObject.simdWorldPosition = result.worldTransform.translation
            
            let previousOrientation = virtualObject.simdWorldTransform.orientation
            let currentOrientation = result.worldTransform.orientation
            virtualObject.simdWorldOrientation = simd_slerp(previousOrientation, currentOrientation, 0.1)
        } else {
            self.setTransform(of: virtualObject, with: result)
        }
    }
    
    // - Tag: ProcessRaycastResults
    private func setVirtualObject3DPosition(_ results: [ARRaycastResult], with virtualObject: VirtualObject) {
        guard let result = results.first else {
            fatalError("Unexpected case: the update handler is always supposed to return at least one result.")
        }
        
        self.setTransform(of: virtualObject, with: result)
        
        // If the virtual object is not yet in the scene, add it.
        if virtualObject.parent == nil {
            self.sceneView.scene.rootNode.addChildNode(virtualObject)
            virtualObject.shouldUpdateAnchor = true
        }
        
        if virtualObject.shouldUpdateAnchor {
            virtualObject.shouldUpdateAnchor = false
            self.updateQueue.async {
                self.sceneView.addOrUpdateAnchor(for: virtualObject)
            }
        }
    }
    
    func setTransform(of virtualObject: VirtualObject, with result: ARRaycastResult) {
        virtualObject.simdWorldTransform = result.worldTransform
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
