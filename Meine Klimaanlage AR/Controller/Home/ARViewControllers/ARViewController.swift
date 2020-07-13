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
    @IBOutlet weak var sceneView: VirtualObjectARView!
    
    @IBOutlet weak var addObjectButton: UIButton!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var upperControlsView: UIView!
    
    @IBOutlet weak var instructionsContainerView: UIView!
    
    @IBOutlet weak var instructionsLabel: UILabel!
    
    @IBOutlet weak var wireButtonStackView: UIStackView!
    
    @IBOutlet weak var addWireButton: UIButton!
    
    @IBOutlet weak var saveUnitButton: UIButton!
    
    @IBOutlet weak var captureButton: UIButton!
    
    @IBOutlet weak var addAnotherUnitOrFinishStackView: UIStackView!
    
    
    //MARK: - UI Elements
    internal let coachingOverlay = ARCoachingOverlayView()
    
    internal var focusSquare = FocusSquare()
    
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    //MARK: - ARKit Configuration Properties
    
    /// A type which manages gesture manipulation of virtual content in the scene.
    lazy var virtualObjectInteraction = VirtualObjectInteraction(sceneView: sceneView, viewController: self)
    
    /// Coordinates the loading and unloading of reference nodes for virtual objects.
    let virtualObjectLoader = VirtualObjectLoader()
    
    /// Marks if the AR experience is available for restart.
    var isRestartAvailable = true
    
    var acUnitHasBeenPlaced = false
    
    var userIsAddingWire = false
    
    /// A serial queue used to coordinate adding or removing nodes from the scene.
    let updateQueue = DispatchQueue(label: "com.martinmaly.Meinde-Klimaanlage-AR")
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    var wirePoints: [SCNVector3] = []
    
    //MARK: - Quote
    public var quote: ACQuote!
    
    public var currentACUnit: ACUnit! {
        return quote.units.last!
    }
    
    public var currentWire: ACWire? {
        get {
            return quote.wires.last!
        }
        set {
            if let wire = newValue {
                quote.wires.removeLast()
                quote.wires.append(wire)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true

        sceneView.debugOptions = .showFeaturePoints
        
        //setup coaching overlay
        setUpCoachingOverlay()
        
        // Set up scene content.
        sceneView.scene.rootNode.addChildNode(focusSquare)
        
        
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userPressedAddUnit))
        // Set the delegate to ensure this gesture is only used when there are no virtual objects in the scene.
        tapGesture.delegate = self
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start the `ARSession`.
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.pause()
    }
    
    private func setUpUI() {
        title = currentACUnit.displayName
        
        addObjectButton.setTitle("Add \(currentACUnit.displayName)", for: .normal)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - Session management
    
    /// Creates a new AR configuration to run on the `session`.
    func resetTracking() {
        virtualObjectInteraction.selectedObject = nil
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        statusViewController.scheduleMessage("FIND A SURFACE TO PLACE THE AC UNIT", inSeconds: 7.5, messageType: .planeEstimation)
    }
    
    // MARK: - Focus Square
    
    func updateFocusSquare(isObjectVisible: Bool) {
        if isObjectVisible || coachingOverlay.isActive {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
            statusViewController.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
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
                updateAddObjectButton(isEnabled: true)
            }
            statusViewController.cancelScheduledMessage(for: .focusSquare)
        } else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
            updateAddObjectButton(isEnabled: false)
        }
    }
    
    // MARK: - Error handling
    
    func displayErrorMessage(title: String, message: String) {
        // Blur the background.
        blurView.isHidden = false
        
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.blurView.isHidden = true
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func updateAddObjectButton(isEnabled: Bool) {
        addObjectButton.isEnabled = isEnabled
        UIView.animate(withDuration: 0.5) {
            self.addObjectButton.alpha = isEnabled ? 1 : 0.25
        }
    }
    
    internal func acUnitWasAdded() {
        acUnitHasBeenPlaced = true
        
        sceneView.scene.rootNode.opacity = 0.5
        
        instructionsContainerView.isHidden = false
        instructionsLabel.text = "Note: You can tap and drag around to position the AC Unit."
        
        addObjectButton.setTitle("Confirm Position", for: .normal)
    }
    
    internal func acUnitWasConfirmed() {
        sceneView.scene.rootNode.opacity = 1
        
        instructionsContainerView.isHidden = true
        addObjectButton.isHidden = true
        
        wireButtonStackView.isHidden = false
    }
}
