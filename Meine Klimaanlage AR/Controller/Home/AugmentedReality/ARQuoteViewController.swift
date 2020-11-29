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
    @IBOutlet weak var confirmUnitPositionButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var chooseWireButton: UIButton!
    @IBOutlet weak var addWireButton: UIButton!
    @IBOutlet weak var captureScreenshotButton: UIButton!
    @IBOutlet weak var doneAddingWireButton: UIButton!
    
    var coachingOverlay = ARCoachingOverlayView()
    var focusSquare = FocusSquare()
    var wireCursor = WireCursor()
    
    //handling app state
    var previousAppState: AppState?
    var appState: AppState = .lookingForSurface
    var statusMessage = ""
    
    //data that is passed in
    var quote: ACQuote!
    
    var currentACUnit: ACUnit! {
        return quote.units.last!
    }
    
    var currentWire: ACWire! {
        return quote.wires.last!
    }
    
    var wireVertexPositions: [SCNVector3] = []
    var wireNodes: [SCNNode] = []
    var currentWireNode: SCNNode?
    
    var planeDetection: ARWorldTrackingConfiguration.PlaneDetection {
        return currentACUnit.environmentType == .interior ? .vertical : .horizontal
    }
    
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
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
        
        if let topSafeAreaInset = UIApplication.shared.windows.first?.safeAreaInsets.top {
            statusLabelHeightConstraint.constant += topSafeAreaInset
            statusLabelCenterYConstraint.constant = topSafeAreaInset / 2
        }
        
        //add unit button
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
        
        //skip button
        continueButton.layer.cornerRadius = 14
        continueButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        continueButton.layer.borderWidth = 1
        
        continueButton.layer.shadowColor = Constants.Color.border.cgColor
        continueButton.layer.shadowRadius = 2
        continueButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        continueButton.layer.shadowOpacity = 0.3
        
        //done adding wire button
        doneAddingWireButton.layer.cornerRadius = 14
        doneAddingWireButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        doneAddingWireButton.layer.borderWidth = 1
        
        doneAddingWireButton.layer.shadowColor = Constants.Color.border.cgColor
        doneAddingWireButton.layer.shadowRadius = 2
        doneAddingWireButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        doneAddingWireButton.layer.shadowOpacity = 0.3
        
        //confirm unit position
        confirmUnitPositionButton.layer.cornerRadius = 14
        confirmUnitPositionButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        confirmUnitPositionButton.layer.borderWidth = 1
        
        confirmUnitPositionButton.layer.shadowColor = Constants.Color.border.cgColor
        confirmUnitPositionButton.layer.shadowRadius = 2
        confirmUnitPositionButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        confirmUnitPositionButton.layer.shadowOpacity = 0.3
        
        //choose wire
        chooseWireButton.layer.cornerRadius = 14
        chooseWireButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        chooseWireButton.layer.borderWidth = 1
        
        chooseWireButton.layer.shadowColor = Constants.Color.border.cgColor
        chooseWireButton.layer.shadowRadius = 2
        chooseWireButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        chooseWireButton.layer.shadowOpacity = 0.3
        
        //add wire
        addWireButton.layer.cornerRadius = 40
        addWireButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        addWireButton.layer.borderWidth = 1
        
        addWireButton.layer.shadowColor = Constants.Color.border.cgColor
        addWireButton.layer.shadowRadius = 2
        addWireButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        addWireButton.layer.shadowOpacity = 0.3
        addWireButton.setImage(largeBoldDoc, for: .normal)
        
        //capture screenshot
        captureScreenshotButton.layer.cornerRadius = 14
        captureScreenshotButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        captureScreenshotButton.layer.borderWidth = 1
        
        captureScreenshotButton.layer.shadowColor = Constants.Color.border.cgColor
        captureScreenshotButton.layer.shadowRadius = 2
        captureScreenshotButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        captureScreenshotButton.layer.shadowOpacity = 0.3
    }
    
    private func setUpScene() {
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
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
    
    private func handleUnitPlaced() {
        self.wireCursor.recentFocusSquarePositions = self.focusSquare.recentFocusSquarePositions
        self.appState = .ACUnitAdded
    }
    
    private func setUpARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            ErrorManager.showARError(with: .notSupported, resultHandler: nil, on: self)
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
        configuration.planeDetection = planeDetection
        configuration.isLightEstimationEnabled = true
        
        return configuration
    }
    
    private func hideAllButtonsIfNeeded() {
        if continueButton.alpha == 1 {
            continueButton.alpha = 0
            continueButton.isUserInteractionEnabled = false
        }
        
        if doneAddingWireButton.alpha == 1 {
            doneAddingWireButton.alpha = 0
            doneAddingWireButton.isUserInteractionEnabled = false
        }
        
        if addUnitButton.alpha == 1 {
            addUnitButton.alpha = 0
            addUnitButton.isUserInteractionEnabled = false
        }
        
        if confirmUnitPositionButton.alpha == 1 {
            confirmUnitPositionButton.alpha = 0
        }
        
        if chooseWireButton.alpha == 1 {
            chooseWireButton.alpha = 0
            chooseWireButton.isUserInteractionEnabled = false
        }
        
        if addWireButton.alpha == 1 {
            addWireButton.alpha = 0
            addWireButton.isUserInteractionEnabled = false
        }
        
        if captureScreenshotButton.alpha == 1 {
            captureScreenshotButton.alpha = 0
            captureScreenshotButton.isUserInteractionEnabled = false
        }
    }
    
    private func showButtonIfNeeded(_ buttonToShow: UIButton) {
        if buttonToShow.alpha == 0 {
            buttonToShow.alpha = 1
            buttonToShow.isUserInteractionEnabled = true
        }
    }
    
    private func updateButtonTintIfNeeded(_ buttonToTint: UIButton) {
        if buttonToTint.tintColor != currentWire.getWireColor() {
            buttonToTint.tintColor = currentWire.getWireColor()
        }
    }
    
    func updateUIForAppState() {
        guard previousAppState != appState else {
            return
        }
        previousAppState = appState
        
        updateStatusText()
        hideAllButtonsIfNeeded()
        
        UIView.animate(withDuration: 0.3) {
            switch self.appState {
            case .lookingForSurface, .pointToSurface: break //all elements should be hidden
            case .readyToAddACUnit:
                self.showButtonIfNeeded(self.addUnitButton)
            case .ACUnitBeingAdded: break //all elements should be hidden
            case .ACUnitAdded:
                self.showButtonIfNeeded(self.confirmUnitPositionButton)
            case .chooseTypeOfWire:
                self.showButtonIfNeeded(self.continueButton)
                self.showButtonIfNeeded(self.chooseWireButton)
            case .addingWire:
                self.showButtonIfNeeded(self.addWireButton)
                self.updateButtonTintIfNeeded(self.addWireButton)
                self.showButtonIfNeeded(self.doneAddingWireButton)
            case .captureScreenshot:
                self.showButtonIfNeeded(self.captureScreenshotButton)
            }
        }
    }
    
    // Updates the status text displayed at the top of the screen.
    func updateStatusText() {
        switch appState {
        case .lookingForSurface:
            statusMessage = "Scan the room with your device until a \(planeDetection == .vertical ? "vertical" : "horizontal") surface is detected."
        case .pointToSurface:
            statusMessage = "Point your device towards one of the detected surfaces."
        case .readyToAddACUnit:
            statusMessage = "Tap on the blue plus to place \(currentACUnit.displayName)."
        case .ACUnitBeingAdded:
            statusMessage = "\(currentACUnit.displayName) is loading. Please wait."
        case .ACUnitAdded:
            statusMessage = "\(currentACUnit.displayName) added! You can drag/rotate the unit to reposition it."
        case .chooseTypeOfWire:
            statusMessage = "Select the type of wire you'd like to add."
        case .addingWire:
            statusMessage = "Press the plus to place \(currentWire.wireDisplayName), and then again whenver you want to add a corner. Tap 'continue' when you're done."
        case .captureScreenshot:
            statusMessage = "Place the \(currentACUnit.displayName) in view, and press 'Capture' to take a screenshot."
        }
        
        statusLabel.text = statusMessage
    }
    
    // MARK: - Cursor stuff
    
    
    func updateCursor(isObjectVisible: Bool) {
        if appState == .lookingForSurface || appState == .pointToSurface || appState == .readyToAddACUnit {
            wireCursor.hide()
            updateFocusSquare(isObjectVisible: isObjectVisible)
        } else if appState == .addingWire {
            focusSquare.hide()
            updateWireCursor()
        } else {
            wireCursor.hide()
            focusSquare.hide()
        }
    }
    
    func updateFocusSquare(isObjectVisible: Bool) {
        if isObjectVisible || coachingOverlay.isActive {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
        }
        
        #warning("unhardcode ray cast orientation ")
        // Perform ray casting only when ARKit tracking is in a good state.
        if let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
           let query = sceneView.getRaycastQuery(for: .vertical),
           let result = sceneView.castRay(for: query).first {
            
            updateQueue.async {
                self.appState = .readyToAddACUnit
                self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(raycastResult: result, camera: camera)
            }
            if !coachingOverlay.isActive {
                addUnitButton.isHidden = false
            }
        } else {
            updateQueue.async {
                self.appState = .pointToSurface
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
            addUnitButton.isHidden = true
        }
    }
    
    func updateWireCursor() {
        if appState == .chooseTypeOfWire {
            wireCursor.hide()
        } else {
            wireCursor.unhide()
        }
        
        // Perform ray casting only when ARKit tracking is in a good state.
        if let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
           let query = sceneView.getRaycastQuery(for: .any),
           let result = sceneView.castRay(for: query).first {
            
            //this code allows wire cursor to be visible even if by dimming object in front
            if let loadedObject = self.sceneView.virtualObject(at: self.sceneView.center) {
                loadedObject.opacity = 0.8
            } else {
                virtualObjectLoader.loadedObjects.forEach({ $0.opacity = 1 })
            }
           
            updateQueue.async {
                self.sceneView.scene.rootNode.addChildNode(self.wireCursor)
                self.wireCursor.state = .detecting(raycastResult: result, camera: camera)
                self.updatePreviewWire()
            }
            if !coachingOverlay.isActive {
                
            }
        } else {
            updateQueue.async {
                self.wireCursor.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.wireCursor)
            }
        }
    }
    
    private func updatePreviewWire() {
        if let mostRecentVertexPosition = wireVertexPositions.last {
            if let currentWireNode = currentWireNode,
               !wireNodes.contains(currentWireNode) {
                currentWireNode.removeFromParentNode()
            }
            
            let wireLine = SCNNode().buildLineInTwoPointsWithRotation(
                from: wireCursor.position,
                to: mostRecentVertexPosition,
                radius: 0.01,
                color: currentWire.getWireColor(),
                dottedLine: currentWire.wireLocation == .insideWall
            )
            
            sceneView.scene.rootNode.addChildNode(wireLine)
            currentWireNode = wireLine
        }
    }
}

extension ARQuoteViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let isAnyObjectInView = virtualObjectLoader.loadedObjects.contains { object in
            return sceneView.isNode(object, insideFrustumOf: sceneView.pointOfView!)
        }
        
        DispatchQueue.main.async {
            self.updateCursor(isObjectVisible: isAnyObjectInView)
            self.updateUIForAppState()
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
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        ErrorManager.showARError(
            with: .sessionFailed,
            resultHandler: { _ in
                self.navigationController?.popViewController(animated: true)
            },
            on: self
        )
    }
}

//MARK: - adding and removing ac units
extension ARQuoteViewController {
    @IBAction func userPressedContinue() {
        appState = .captureScreenshot
    }
    
    @IBAction func userPressedCaptureScreenshot() {
        let image = sceneView.snapshot()
        quote.screenshots.append(image)
        
        let vc = QuoteSummaryViewController()
        vc.quote = quote
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func userPressedChooseWire() {
        let chooseWireVC = ChooseTypeOfWireViewController(arViewController: self)
        let navigationController = UINavigationController(rootViewController: chooseWireVC)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func userPressedConfirmUnitPosition() {
        appState = .chooseTypeOfWire
    }
    
    @IBAction func userPressedAddWire() {
        let wireCursorCopy = wireCursor.copy() as! WireCursor
       
        // Right now, node2 is sharing geometry. This changes the color of both:
        wireCursor.geometry?.firstMaterial?.diffuse.contents = Constants.Color.primaryBlue

        // Un-share the geometry by copying
        wireCursorCopy.geometry = wireCursor.geometry!.copy() as? SCNGeometry
        // Un-share the material, too
        wireCursorCopy.geometry?.firstMaterial = wireCursor.geometry!.firstMaterial!.copy() as? SCNMaterial
        // Now, we can change node2's material without changing node1's:
        //maybe change this color to the color of the desired wire?
        wireCursorCopy.geometry?.firstMaterial?.diffuse.contents = currentWire.getWireColor()
        wireCursorCopy.scale = SCNVector3(1.5, 1.5, 1.5)
        
        //store nodes
        wireVertexPositions.append(wireCursorCopy.position)
        
        //update array storing wires
        if let currentWireNode = currentWireNode {
            wireNodes.append(currentWireNode)
            self.currentWireNode = nil
        }
        
        //add copy to scene
        self.sceneView.scene.rootNode.addChildNode(wireCursorCopy)
    }
    
    @IBAction func userPressedDoneAddingWire() {
        if currentWireNode != nil {
            //remove final node
            userPressedAddWire()
        }
        
        //update quote with wire information
        var totalLength: Float = 0
        var previousPosition: SCNVector3?
        
        for currentPosition in wireVertexPositions {
            //not run if only one eleemtn in array
            if let previousPosition = previousPosition {
                let w = SCNVector3(
                    x: currentPosition.x - previousPosition.x,
                    y: currentPosition.y - previousPosition.y,
                    z: currentPosition.z - previousPosition.z
                )
                
                totalLength += sqrt(w.x * w.x + w.y * w.y + w.z * w.z)
            }
            previousPosition = currentPosition
        }
        
        var indexToRemove: Int?
        for (index, wire) in quote.wires.enumerated() where currentWire.isSameWire(as: wire) && !wire.isSameWire(as: quote.wires.last) {
            totalLength += wire.wireLength
            indexToRemove = index
        }
        
        let newWire = ACWire(wire: currentWire, wireLength: totalLength)
        
        if let indexToRemove = indexToRemove {
            quote.wires.remove(at: indexToRemove)
        }
        
        quote.wires.removeLast()
        quote.wires.append(newWire)
        
        //reset all variables
        wireVertexPositions.removeAll()
        wireNodes.removeAll()
        currentWireNode = nil
    
        appState = .chooseTypeOfWire
    }
    
    @IBAction func userPressedAddUnitButton() {
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
                                self.placeVirtualObject(loadedObject)
                                self.handleUnitPlaced()
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
        
        //remove coaching overlay from session (to ensure it's not restarted)
        coachingOverlay.session = nil
    }
    
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        //TODO: reset
    }
}
