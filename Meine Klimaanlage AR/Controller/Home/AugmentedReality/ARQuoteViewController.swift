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
    @IBOutlet weak var addWireButton: UIButton!
    @IBOutlet weak var addAnotherUnitButton: UIButton!
    @IBOutlet weak var placeWireButton: UIButton!
    @IBOutlet weak var captureScreenshotButton: UIButton!
    @IBOutlet weak var doneAddingWireButton: UIButton!
    private var coachingOverlayStatusLabel: UILabel!
    private var coachingOverlayStatusVisualEffectView: UIVisualEffectView!
    
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
        addWireButton.layer.cornerRadius = 14
        addWireButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        addWireButton.layer.borderWidth = 1
        
        addWireButton.layer.shadowColor = Constants.Color.border.cgColor
        addWireButton.layer.shadowRadius = 2
        addWireButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        addWireButton.layer.shadowOpacity = 0.3
        
        //add another unit
        addAnotherUnitButton.layer.cornerRadius = 14
        addAnotherUnitButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        addAnotherUnitButton.layer.borderWidth = 1
        
        addAnotherUnitButton.layer.shadowColor = Constants.Color.border.cgColor
        addAnotherUnitButton.layer.shadowRadius = 2
        addAnotherUnitButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        addAnotherUnitButton.layer.shadowOpacity = 0.3
        
        //add wire
        placeWireButton.layer.cornerRadius = 40
        placeWireButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        placeWireButton.layer.borderWidth = 1
        
        placeWireButton.layer.shadowColor = Constants.Color.border.cgColor
        placeWireButton.layer.shadowRadius = 2
        placeWireButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        placeWireButton.layer.shadowOpacity = 0.3
        placeWireButton.setImage(largeBoldDoc, for: .normal)
        
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
        sceneView.session.delegate = self
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
        
        let blurEffect = UIBlurEffect(style: .regular)
        coachingOverlayStatusVisualEffectView = UIVisualEffectView(effect: blurEffect)
        coachingOverlayStatusVisualEffectView.layer.cornerRadius = 8
        coachingOverlayStatusVisualEffectView.clipsToBounds = true
        coachingOverlayStatusVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        coachingOverlay.addSubview(coachingOverlayStatusVisualEffectView)
        
        coachingOverlayStatusVisualEffectView.topAnchor.constraint(equalTo: coachingOverlay.safeAreaLayoutGuide.topAnchor).isActive = true
        coachingOverlayStatusVisualEffectView.leadingAnchor.constraint(equalTo: coachingOverlay.leadingAnchor, constant: 15).isActive = true
        coachingOverlayStatusVisualEffectView.leadingAnchor.constraint(lessThanOrEqualTo:coachingOverlay.leadingAnchor, constant: -15).isActive = true
        
        coachingOverlayStatusLabel = UILabel()
        coachingOverlayStatusVisualEffectView.contentView.addSubview(coachingOverlayStatusLabel)
        coachingOverlayStatusLabel.translatesAutoresizingMaskIntoConstraints = false

        coachingOverlayStatusLabel.leadingAnchor.constraint(equalTo: coachingOverlayStatusVisualEffectView.contentView.leadingAnchor, constant: 15).isActive = true
        coachingOverlayStatusLabel.trailingAnchor.constraint(equalTo: coachingOverlayStatusVisualEffectView.contentView.trailingAnchor, constant: -15).isActive = true
        coachingOverlayStatusLabel.topAnchor.constraint(equalTo: coachingOverlayStatusVisualEffectView.contentView.topAnchor, constant: 10).isActive = true
        coachingOverlayStatusLabel.bottomAnchor.constraint(equalTo: coachingOverlayStatusVisualEffectView.contentView.bottomAnchor, constant: -10).isActive = true
        
        coachingOverlayStatusVisualEffectView.isHidden = true

        let coachingOverlayExtraHelpContainerView = UIView()
        coachingOverlayExtraHelpContainerView.backgroundColor = Constants.Color.primaryWhiteBackground
        coachingOverlayExtraHelpContainerView.layer.cornerRadius = 8
        coachingOverlayExtraHelpContainerView.translatesAutoresizingMaskIntoConstraints = false
        coachingOverlay.addSubview(coachingOverlayExtraHelpContainerView)
        coachingOverlayExtraHelpContainerView.translatesAutoresizingMaskIntoConstraints = false
        coachingOverlayExtraHelpContainerView.bottomAnchor.constraint(
            equalTo: coachingOverlay.bottomAnchor,
            constant: -30
        ).isActive = true
        coachingOverlayExtraHelpContainerView.widthAnchor.constraint(equalToConstant:UIScreen.main.bounds.width * 2/3).isActive = true
        coachingOverlayExtraHelpContainerView.centerXAnchor.constraint(equalTo: coachingOverlay.centerXAnchor).isActive = true
        
        let coachingOverlayExtraHelpStackView = UIStackView()
        coachingOverlayExtraHelpStackView.axis = .horizontal
        coachingOverlayExtraHelpStackView.alignment = .center
        coachingOverlayExtraHelpStackView.distribution = .fillProportionally
        coachingOverlayExtraHelpStackView.spacing = 8
        
        coachingOverlayExtraHelpContainerView.addSubview(coachingOverlayExtraHelpStackView)
        coachingOverlayExtraHelpStackView.translatesAutoresizingMaskIntoConstraints = false
        coachingOverlayExtraHelpStackView.leadingAnchor.constraint(equalTo: coachingOverlayExtraHelpContainerView.leadingAnchor, constant: 15).isActive = true
        coachingOverlayExtraHelpStackView.trailingAnchor.constraint(equalTo: coachingOverlayExtraHelpContainerView.trailingAnchor, constant: -15).isActive = true
        coachingOverlayExtraHelpStackView.topAnchor.constraint(equalTo: coachingOverlayExtraHelpContainerView.topAnchor, constant: 10).isActive = true
        coachingOverlayExtraHelpStackView.bottomAnchor.constraint(equalTo: coachingOverlayExtraHelpContainerView.bottomAnchor, constant: -10).isActive = true
        
        let coachingOverlayExtraHelpLabel = UILabel()
        coachingOverlayExtraHelpLabel.numberOfLines = 0
        coachingOverlayExtraHelpLabel.text = "Keep moving your device to scan the room in front of you until it detects a surface. This can sometimes take a couple of minutes. If no surfaces are detected, try walking around or changing the lighting in the room."
        coachingOverlayExtraHelpLabel.textColor = Constants.Color.primaryTextDark
        coachingOverlayExtraHelpStackView.addArrangedSubview(coachingOverlayExtraHelpLabel)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        coachingOverlayExtraHelpStackView.addArrangedSubview(activityIndicator)
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
        
        if addWireButton.alpha == 1 {
            addWireButton.alpha = 0
            addWireButton.isUserInteractionEnabled = false
        }
        
        if addAnotherUnitButton.alpha == 1 {
            addAnotherUnitButton.alpha = 0
            addAnotherUnitButton.isUserInteractionEnabled = false
        }
        
        if placeWireButton.alpha == 1 {
            placeWireButton.alpha = 0
            placeWireButton.isUserInteractionEnabled = false
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
            case .chooseToAddAnotherObjectToScene:
                self.showButtonIfNeeded(self.continueButton)
                self.showButtonIfNeeded(self.addWireButton)
                self.showButtonIfNeeded(self.addAnotherUnitButton)
            case .placingWire:
                self.showButtonIfNeeded(self.placeWireButton)
                self.updateButtonTintIfNeeded(self.placeWireButton)
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
        case .chooseToAddAnotherObjectToScene:
            statusMessage = "Select whether you'd like to add a wire or another unit to the scene. Or tap 'continue' to move on."
        case .placingWire:
            statusMessage = "Press the plus to place \(currentWire.wireDisplayName), and then again whenver you want to add a corner. Tap 'Done' when you're done."
        case .captureScreenshot:
            statusMessage = "Place the \(currentACUnit.displayName) in view, and press 'Capture' to take a screenshot."
        }
        
        statusLabel.text = statusMessage
    }
    
    //update the session label when in coaching overlay mode
    private func updateCoachingOverlayStatusLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        guard coachingOverlay.isActive else { return }
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String

        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal and vertical surfaces."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""

        }

        coachingOverlayStatusLabel.text = message
        coachingOverlayStatusVisualEffectView.isHidden = message.isEmpty
    }

    
    // MARK: - Cursor stuff
    
    
    func updateCursor(isObjectVisible: Bool) {
        if appState == .lookingForSurface || appState == .pointToSurface || appState == .readyToAddACUnit {
            wireCursor.hide()
            updateFocusSquare(isObjectVisible: isObjectVisible)
        } else if appState == .placingWire {
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
        
        let alignment: ARRaycastQuery.TargetAlignment = planeDetection == .vertical ? .vertical :  .horizontal
        // Perform ray casting only when ARKit tracking is in a good state.
        if let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
           let query = sceneView.getRaycastQuery(for: alignment),
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
        if appState == .chooseToAddAnotherObjectToScene {
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

extension ARQuoteViewController: ARSCNViewDelegate, ARSessionDelegate {
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
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateCoachingOverlayStatusLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateCoachingOverlayStatusLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        guard let frame = session.currentFrame else { return }
        updateCoachingOverlayStatusLabel(for: frame, trackingState: camera.trackingState)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        guard coachingOverlay.isActive else { return }
        coachingOverlayStatusVisualEffectView.isHidden = false
        coachingOverlayStatusLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        guard coachingOverlay.isActive else { return }
        coachingOverlayStatusVisualEffectView.isHidden = false
        coachingOverlayStatusLabel.text = "Session interruption ended"
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
    
    @IBAction func userPressedAddWire() {
        let chooseWireVC = ChooseTypeOfWireViewController(arViewController: self)
        let navigationController = UINavigationController(rootViewController: chooseWireVC)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func userPressedAddAnotherUnit() {
        ErrorManager.showFeatureNotSupported(on: self)
    }
    
    @IBAction func userPressedConfirmUnitPosition() {
        sceneView.removeAllGestureRecognizers()
        
        appState = .chooseToAddAnotherObjectToScene
    }
    
    @IBAction func userPressedPlaceWire() {
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
            userPressedPlaceWire()
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
        
        let newWire = ACWire(wire: currentWire, wireLength: totalLength)
        quote.wires.removeLast()
        quote.wires.append(newWire)
        
        //reset all variables
        wireVertexPositions.removeAll()
        wireNodes.removeAll()
        currentWireNode = nil
    
        appState = .chooseToAddAnotherObjectToScene
    }
    
    @IBAction func userPressedAddUnitButton() {
        // Ensure adding objects is an available action and we are not loading another object (to avoid concurrent modifications of the scene).
        //do we need this?
        guard !virtualObjectLoader.isLoading else { return }
        
        if let filePath = Bundle.main.path(forResource: currentACUnit.fileName, ofType: "scn", inDirectory: "ACUnits.scnassets") {
            let referenceURL = URL(fileURLWithPath: filePath)
            let virtualObject = VirtualObject(url: referenceURL)!
            
            let alignment: ARRaycastQuery.TargetAlignment = planeDetection == .vertical ? .vertical :  .horizontal
            if let query = sceneView.getRaycastQuery(for: alignment),
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
