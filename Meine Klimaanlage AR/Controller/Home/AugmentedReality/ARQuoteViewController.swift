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
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var confirmPositionStackView: UIStackView!
    @IBOutlet weak var addUnitOrFinishStackView: UIStackView!
    @IBOutlet weak var captureStackView: UIStackView!
    @IBOutlet weak var tapOnUnitToPlaceWireStackView: UIStackView!
    @IBOutlet weak var placeWireStackView: UIStackView!
    
    //UI Elements
    private var coachingOverlay = ARCoachingOverlayView()
    
    public var appState: AppState = .noUnitPlaced
    
    //data that is passed in
    public var quote: ACQuote!
    
    private var currentACUnit: ACUnit {
        guard let currentACUnit = quote.units.last else {
            fatalError("Error creating currentACUnit")
        }
        return currentACUnit
    }
    
    private var loadedACUnitNodes: [SCNNode] = []
    
    private var currentACUnitNode: SCNNode? {
        return loadedACUnitNodes.last
    }
    
    //store previous coordinates from hittest to compare with current ones
    private var previousPanCoordinateX: Float?
    private var previousPanCoordinateZ: Float?
    private var trackedObject: SCNNode?
    
    //store previous rotation value for rotating object
    var currentAngleZ: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpScene()
        setUpCoachingOverlay()
        setUpARSession()
    }
    
    private func setUpUI() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
    }
    
    private func setUpScene() {
        sceneView.delegate = self
        sceneView.session.delegate = self
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
        
        coachingOverlay.goal = .tracking
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.delegate = self
        coachingOverlay.session = sceneView.session
        
        coachingOverlay.setActive(true, animated: true)
    }
    
    private func setUpARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            ErrorManager.showARError(with: .notSupported, resultHandler: nil, on: self)
            return
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        //detect both horizontal and vertical planes
        
        if currentACUnit.environmentType == .exterior {
            configuration.planeDetection = .horizontal
        } else {
            //no plane detection for vertical (as we use the phone on the wall method)
        }
        
        configuration.isLightEstimationEnabled = true
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    public func addVerticalAnchorCoachingView() {
        //hide reset button
        resetButton.isHidden = true
        //and hide the addObjecttOrFinishStackView (in case it's the second unit that's being added)
        addUnitOrFinishStackView.isHidden = true
        
        //show coaching thing
        let verticalAnchorCoachingView = VerticalAnchorCoachingView()
        verticalAnchorCoachingView.delegate = self
        
        verticalAnchorCoachingView.translatesAutoresizingMaskIntoConstraints = false
        
        sceneView.addSubview(verticalAnchorCoachingView)
        
        verticalAnchorCoachingView.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor).isActive = true
        verticalAnchorCoachingView.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor).isActive = true
        verticalAnchorCoachingView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        verticalAnchorCoachingView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    public func userChoseWire() {
        tapOnUnitToPlaceWireStackView.isHidden = false
        addUnitOrFinishStackView.isHidden = true
        
        //add tap gesture to determine which unit the user tapped?
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userPressedScreen(tapGesture:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
}

extension ARQuoteViewController: ARCoachingOverlayViewDelegate {
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        //
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        //remove coaching overlay from session (to ensure it's not restarted)
        coachingOverlay.session = nil
        
        addVerticalAnchorCoachingView()
    }
    
    private func addACUnit() {
        //add gesutre recognizers so user can pan unit
        addGestureRecognizers()
        
        guard let filePath = Bundle.main.path(forResource: currentACUnit.fileName, ofType: "scn", inDirectory: "ACUnits.scnassets") else {
            fatalError("Could not get AC Uni from filet")
        }
        let referenceURL = URL(fileURLWithPath: filePath)
        
        guard let acUnit = SCNReferenceNode(url: referenceURL),
              let pointOfView = sceneView.pointOfView else {
            fatalError("Could not get currentFrame or pointOfView")
        }
        acUnit.load()
        
        loadedACUnitNodes.append(acUnit.loadedNode)
        
        //set bit mask so it can be located in hit test
        acUnit.loadedNode.categoryBitMask = HitTestType.acUnit.rawValue
        
        let pointOfViewEulerAngle = pointOfView.eulerAngles
        
       
        
        let dimension: CGFloat = 1
        let plane = SCNPlane(width: dimension, height: dimension)
        plane.firstMaterial?.diffuse.contents = UIColor.green
        plane.cornerRadius = dimension / 2
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.blendMode = .max
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.transform = pointOfView.transform
        planeNode.categoryBitMask = HitTestType.plane.rawValue
        
        planeNode.addChildNode(acUnit)
        
        sceneView.scene.rootNode.addChildNode(planeNode)
        
        //give user option to confirm the position after they've manipulated it
        confirmPositionStackView.isHidden = false
        
        //show reset button
        resetButton.isHidden = false
    }
    
    private func addGestureRecognizers() {
        //add gesture recognizers
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(userPannedScreen(_:)))
        sceneView.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(userPinchedScreen(_:)))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
        
        let rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(userRotatedScreen(_:)))
        sceneView.addGestureRecognizer(rotateGestureRecognizer)
    }
    
    private func userPressedChooseWire()  {
        let chooseWireVC = ChooseTypeOfWireViewController()
        let navigationController = UINavigationController(rootViewController: chooseWireVC)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    private func userPressedChooseACUnit()  {
        guard let viewControllerToPresent = storyboard?.instantiateViewController(identifier: "ChooseUnitNavigationController") else {
            fatalError("could not get viewControllerToPresent")
        }
        
        present(viewControllerToPresent, animated: true, completion: nil)
    }
}

//MARK: - gesture recognizer stuff
extension ARQuoteViewController {
    @objc func userPannedScreen(_ panGesture: UIPanGestureRecognizer) {
        let location = panGesture.location(in: sceneView)
        let acUnitBitMask = HitTestType.acUnit.rawValue
        
        switch panGesture.state {
        case .began:
            if let hitTestResult = sceneView.hitTest(
                location,
                options: [SCNHitTestOption.categoryBitMask : acUnitBitMask]
            ).first,
            let acUnit = hitTestResult.node.parent,
            acUnit.isEqual(currentACUnitNode) {
                //user is panning AC unit
                trackedObject = acUnit
                
                previousPanCoordinateX = hitTestResult.localCoordinates.x
                previousPanCoordinateZ = hitTestResult.worldCoordinates.z
            }
        case .changed:
            if let trackedObject = trackedObject,
               let previousPanCoordinateX = previousPanCoordinateX,
               let previousPanCoordinateZ = previousPanCoordinateZ,
               let hitTestResult = sceneView.hitTest(
                location,
                options: [SCNHitTestOption.categoryBitMask : acUnitBitMask]
               ).first,
               let acUnit = hitTestResult.node.parent,
               acUnit.isEqual(trackedObject) {
                let coordx = hitTestResult.worldCoordinates.x
                let coordz = hitTestResult.worldCoordinates.z
                
                let action = SCNAction
                    .moveBy(
                        x: CGFloat(coordx -  previousPanCoordinateX),
                        y: 0,
                        z:  CGFloat(coordz - previousPanCoordinateZ),
                        duration: 0.1
                    )
                
                trackedObject.runAction(action)
                
                self.previousPanCoordinateX = coordx
                self.previousPanCoordinateZ = coordz
            }
            
            panGesture.setTranslation(CGPoint.zero, in: sceneView)
        case .ended:
            trackedObject = nil
            previousPanCoordinateX = nil
            previousPanCoordinateZ = nil
        default:
            break
        }
    }
    
    @objc func userPinchedScreen(_ pinchGesture: UIPinchGestureRecognizer) {
        let location = pinchGesture.location(in: sceneView)
        let acUnitBitMask = HitTestType.acUnit.rawValue
        
        switch pinchGesture.state {
        case .began:
            if let hitTestResult = sceneView.hitTest(
                location,
                options: [SCNHitTestOption.categoryBitMask : acUnitBitMask]
            ).first,
            let acUnit = hitTestResult.node.parent,
            acUnit.isEqual(currentACUnitNode) {
                //user is pinching AC unit
                trackedObject = acUnit
            }
        case .changed:
            if let trackedObject = trackedObject,
               let hitTestResult = sceneView.hitTest(
                location,
                options: [SCNHitTestOption.categoryBitMask : acUnitBitMask]
               ).first,
               let acUnit = hitTestResult.node.parent,
               acUnit.isEqual(trackedObject) {
                let pinchScaleX = pinchGesture.scale * CGFloat((trackedObject.scale.x))
                let pinchScaleY = pinchGesture.scale * CGFloat((trackedObject.scale.y))
                let pinchScaleZ = pinchGesture.scale * CGFloat((trackedObject.scale.z))
                trackedObject.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
                pinchGesture.scale = 1
            }
        case .ended:
            trackedObject = nil
        default:
            break
        }
    }
    
    @objc func userRotatedScreen(_ rotateGesture: UIRotationGestureRecognizer) {
        let location = rotateGesture.location(in: sceneView)
        let acUnitBitMask = HitTestType.acUnit.rawValue
        
        switch rotateGesture.state {
        case .began:
            if let hitTestResult = sceneView.hitTest(
                location,
                options: [SCNHitTestOption.categoryBitMask : acUnitBitMask]
            ).first,
            let acUnit = hitTestResult.node.parent,
            acUnit.isEqual(currentACUnitNode) {
                //user is pinching AC unit
                trackedObject = acUnit
            }
        case .changed:
            if let trackedObject = trackedObject,
               let hitTestResult = sceneView.hitTest(
                location,
                options: [SCNHitTestOption.categoryBitMask : acUnitBitMask]
               ).first,
               let acUnit = hitTestResult.node.parent,
               acUnit.isEqual(trackedObject) {
                trackedObject.eulerAngles.z =  -(currentAngleZ + Float(rotateGesture.rotation))
            }
        case .ended:
            currentAngleZ = trackedObject?.eulerAngles.z ?? 0
            trackedObject = nil
        default:
            break
        }
    }
    
    //handling user choosing which AC unit to add wires onto!
    @objc func userPressedScreen(tapGesture: UITapGestureRecognizer) {
        //check if user tappedUnit
        let location = tapGesture.location(in: sceneView)
        
        let acUnitBitMask = HitTestType.acUnit.rawValue
        
        if let hitTestResult = sceneView.hitTest(
            location,
            options: [
                SCNHitTestOption.categoryBitMask : acUnitBitMask
            ]
        ).first,
        let acUnitNode = hitTestResult.node.parent,
        loadedACUnitNodes.contains(acUnitNode) {
            acUnitNode.removeFromParentNode()
            
            removeGestureRecognizersFromView()
        }
    }
    
    private func removeGestureRecognizersFromView() {
        //call when user has finished placing AC unit
        for gestureRecognizer in sceneView.gestureRecognizers ?? [] {
            sceneView.removeGestureRecognizer(gestureRecognizer)
        }
    }
}

extension ARQuoteViewController: VerticalAnchorCoachingViewDelegate {
    func userPressedPlaceACUnit() {
        addACUnit()
    }
}

extension ARQuoteViewController: ARSCNViewDelegate {
    
}

extension ARQuoteViewController: ARSessionDelegate {
    
}

//MARK: -  Button actions
extension ARQuoteViewController {
    @IBAction func userPressedReset() {
        #warning("TODO")
    }
    
    @IBAction func userPressedConfirmPosition() {
        //hide confirm position stack view
        confirmPositionStackView.isHidden = true
        
        //remove gesture recognzers so user can't move unit
        removeGestureRecognizersFromView()
        
        //show stack view so user can eiher add or
        addUnitOrFinishStackView.isHidden = false
    }
    
    @IBAction func userPressedAddObject() {
        let actionSheet = UIAlertController(
            title: "Add object",
            message: "Choose object to add",
            preferredStyle: .actionSheet
        )
        
        let wireAction = UIAlertAction(
            title: "Wire",
            style: .default,
            handler: { _ in
                self.userPressedChooseWire()
            }
        )
        
        let acUnitAction = UIAlertAction(
            title: "AC Unit",
            style: .default,
            handler: { _ in
                self.userPressedChooseACUnit()
            }
        )
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        
        actionSheet.addAction(wireAction)
        actionSheet.addAction(acUnitAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func userPressedPlaceWire() {
        //TODO
    }
    
    @IBAction func userPressedDonePlacingWire() {
        //TODO
    }
    
    @IBAction func userPressedFinish() {
        addUnitOrFinishStackView.isHidden = true
        //show screenshot stack
        captureStackView.isHidden = false
    }
    
    @IBAction func userPressedCapture() {
        //take a screenshot and move to quote view controller
        let capture = sceneView.snapshot()
        quote.screenshots.append(capture)
        
        //show quote view controller
        let vc = QuoteSummaryViewController()
        vc.quote = quote
        navigationController?.pushViewController(vc, animated: true)
    }
}
