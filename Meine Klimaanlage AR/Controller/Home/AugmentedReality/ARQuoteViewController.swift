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
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var confirmPositionStackView: UIStackView!
    @IBOutlet weak var addObjectOrFinishStackView: UIStackView!
    @IBOutlet weak var captureStackView: UIStackView!
    @IBOutlet weak var tapOnUnitToPlaceWireStackView: UIStackView!
    @IBOutlet weak var placeWireStackView: UIStackView!
    
    //UI Elements
    private var coachingOverlay = ARCoachingOverlayView()
    
    //data that is passed in
    public var quote: ACQuote!
    
    private var currentACUnit: ACUnit {
        guard let currentACUnit = quote.units.last else {
            fatalError("Error creating currentACUnit")
        }
        return currentACUnit
    }
    
    private var currentWire: ACWire {
        guard let currentWire = confirmedWires.last?.wire else {
            fatalError("Could not get current wire")
        }
        return currentWire
    }
    
    //stores all nodes added to the scene in the order
    //they were added. Used to undo addition of node.
    private var loadedNodes: [SCNNode] = []
    
    private var loadedACUnitNodes: [SCNNode] = []
    
    private var currentACUnitNode: SCNNode? {
        return loadedACUnitNodes.last
    }
    
    private var currentPlane: InfinitePlaneNode?
    
    private var wireCursor: WireCursor?
    public var confirmedWires = [ARWire]()
    private var currentWireSegment: WireSegment?
    
    private var currentWireAnchorPoint: SCNVector3?

    //store previous coordinates from hittest to compare with current ones
    private var previousPanCoordinateX: Float?
    private var previousPanCoordinateY: Float?
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
        //hide reset button & undo buttton
        resetButton.isHidden = true
        undoButton.isHidden = true
        
        //and hide the addObjecttOrFinishStackView (in case it's the second unit that's being added)
        addObjectOrFinishStackView.isHidden = true
        
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
        addObjectOrFinishStackView.isHidden = true
        
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
        
        
        let infinitePlaneNode = InfinitePlaneNode()
        infinitePlaneNode.transform = pointOfView.transform
        
        //rotate 90 degrees
        let rotation = simd_quatf(angle: .pi / 2, axis: SIMD3(x: 1, y: 0, z: 0))
        infinitePlaneNode.simdOrientation *= rotation
        
        infinitePlaneNode.addChildNode(acUnit)
        sceneView.scene.rootNode.addChildNode(infinitePlaneNode)
        
        //prefer to add infinitePlaneNode, rather than the AC Unit node itself becuse removing
        //the plane node, will also remove the ac unit.
        loadedNodes.append(infinitePlaneNode)
        
        //give user option to confirm the position after they've manipulated it
        confirmPositionStackView.isHidden = false
        
        //show reset button & undo button
        resetButton.isHidden = false
        undoButton.isHidden = false
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

    private func hideAllUIElements() {
        resetButton.isHidden = true
        undoButton.isHidden = true
        confirmPositionStackView.isHidden = true
        addObjectOrFinishStackView.isHidden = true
        captureStackView.isHidden = true
        tapOnUnitToPlaceWireStackView.isHidden = true
        placeWireStackView.isHidden = true
    }
    
    private func showAddObjectOrFinishStackView() {
        hideAllUIElements()
        
        resetButton.isHidden = false
        undoButton.isHidden = false
        
        addObjectOrFinishStackView.isHidden = false
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
                
                previousPanCoordinateX = Float(location.x)
                previousPanCoordinateY = Float(location.y)
            }
        case .changed:
            if let trackedObject = trackedObject,
               let previousPanCoordinateX = previousPanCoordinateX,
               let previousPanCoordinateY = previousPanCoordinateY {
                let coordx = Float(location.x)
                let coordy = Float(location.y)
                
                let action = SCNAction
                    .moveBy(
                        x: CGFloat(coordx -  previousPanCoordinateX) / 150,
                        y: -CGFloat(coordy - previousPanCoordinateY) / 150,
                        z:  0,
                        duration: 0.1
                    )
                
                trackedObject.runAction(action)
                
                self.previousPanCoordinateX = coordx
                self.previousPanCoordinateY = coordy
            }
            
            panGesture.setTranslation(CGPoint.zero, in: sceneView)
        case .ended:
            trackedObject = nil
            previousPanCoordinateX = nil
            previousPanCoordinateY = nil
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
        loadedACUnitNodes.contains(acUnitNode),
        let infinitePlaneNode = acUnitNode.grandParent as? InfinitePlaneNode {
            //update UI for plane being found
            tapOnUnitToPlaceWireStackView.isHidden = true
            placeWireStackView.isHidden = false
            
            self.currentPlane = infinitePlaneNode
            
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
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            if let currentPlane = self.currentPlane {
                //user is placing wire
                if let hitTestResult = self.sceneView.hitTest(
                    self.sceneView.center,
                    options: [
                        SCNHitTestOption.categoryBitMask : HitTestType.plane.rawValue
                    ]
                ).first {
                    let locationOfIntersection = hitTestResult.localCoordinates
                    
                    if let wireCursor = self.wireCursor {
                        
                        if let currentWireAnchorPoint = self.currentWireAnchorPoint {
                            
                            if let currentWireSegment = self.currentWireSegment,
                               let currentWireSegments = self.confirmedWires.last?.segments,
                               !currentWireSegments.contains(currentWireSegment) {
                                currentWireSegment.removeFromParentNode()
                            }
                            
                            let wireSegment = WireSegment(
                                from: currentWireAnchorPoint,
                                to: wireCursor.position,
                                radius: 0.015,
                                color: self.currentWire.getWireColor(),
                                dottedLine: self.currentWire.wireLocation == .insideWall
                            )
                            currentPlane.addChildNode(wireSegment)
                            
                            wireSegment.buildLineInTwoPointsWithRotation()
                            
                            self.currentWireSegment = wireSegment
                        }
                        
                        if abs(locationOfIntersection.x) < 0.1 && abs(locationOfIntersection.y) < 0.1 && abs(locationOfIntersection.z) < 0.1 {
                            #warning("fix this bug in better way!!")
                            return
                        }
                        
                        
                        wireCursor.position = locationOfIntersection
                        wireCursor.position.z = 0.1
                    } else {
                        self.wireCursor = WireCursor()
                        
                        guard let wireCursor = self.wireCursor else {
                            fatalError("Could not create wirecursor")
                        }
                        
                        currentPlane.addChildNode(wireCursor)
                        
                        self.wireCursor?.position = locationOfIntersection
                        self.wireCursor?.position.z = 0.1
                        
                        self.loadedNodes.append(wireCursor)
                    }
                }
            }
        }
    }
}

extension ARQuoteViewController: ARSessionDelegate {
    
}

//MARK: -  Button actions
extension ARQuoteViewController {
    @IBAction func userPressedReset() {
        //reset quote back to it's initial state
        //remove all units (except first, since there must exist at least one)
        self.quote.units = Array(self.quote.units.dropFirst(1))
        
        //remove all nodes
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        
        //set all properties to nil, and empty all arrays
        loadedNodes.removeAll()
        loadedACUnitNodes.removeAll()
        currentPlane = nil
        wireCursor = nil
        confirmedWires.removeAll()
        currentWireAnchorPoint = nil
        currentWireSegment = nil
        previousPanCoordinateX = nil
        previousPanCoordinateY = nil
        trackedObject = nil
        currentAngleZ = 0.0
        
        //hide all existing uii elemnts
        hideAllUIElements()
        
        //show coaching
        addVerticalAnchorCoachingView()
    }
    
    @IBAction func userPressedUndo() {
        //specially handle case when recentlyAddedNode is WireCursor
        if let recentlyAddedNode = loadedNodes.last,
           recentlyAddedNode is WireCursor {
            if let currentWireSegment = currentWireSegment {
                currentWireSegment.removeFromParentNode()
                self.currentWireSegment = nil
                currentWireAnchorPoint = nil
            } else {
                _ = loadedNodes.popLast()
                _ = confirmedWires.popLast()
                
                recentlyAddedNode.removeFromParentNode()
                wireCursor = nil
                currentPlane = nil
                showAddObjectOrFinishStackView()
            }
    
            return
        }
    
        //otherwise, do tthe following
        if let recentlyAddedNode = loadedNodes.popLast() {
            recentlyAddedNode.removeFromParentNode()
            
            if recentlyAddedNode is InfinitePlaneNode {
                //remove ac unit from loadedACUnitNodes as well
                _ = loadedACUnitNodes.popLast()
                
                if loadedACUnitNodes.isEmpty {
                    //user has removed all nodes using undo button
                    //show coaching
                    userPressedReset()
                } else {
                    _ = quote.units.popLast()
                    //there still exists some units, so add the add object view
                    showAddObjectOrFinishStackView()
                }
            } else if recentlyAddedNode is WireSegment {
                let removedSegment = confirmedWires.last?.segments.popLast()
                
                currentWireAnchorPoint = removedSegment?.startPoint
            } else {
                fatalError("Unknown ype")
            }
        }
    }
    
    @IBAction func userPressedConfirmPosition() {
        //hide confirm position stack view
        confirmPositionStackView.isHidden = true
        
        //remove gesture recognzers so user can't move unit
        removeGestureRecognizersFromView()
        
        //show stack view so user can eiher add or
        addObjectOrFinishStackView.isHidden = false
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
        
        actionSheet.popoverPresentationController?.sourceView = addObjectOrFinishStackView
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func userPressedPlaceWire() {
        guard let wireCursorPosition = wireCursor?.position else {
            fatalError("Couldn't get position of wireCursor")
        }
        
        //set anchor point
        currentWireAnchorPoint = wireCursorPosition
        
        if let currentWireSegment = currentWireSegment {
            confirmedWires.last?.segments.append(currentWireSegment)
            loadedNodes.append(currentWireSegment)
        }
    }
    
    @IBAction func userPressedDonePlacingWire() {
        userPressedPlaceWire()
        
        //update UI so user can either add another unit or wire
        addObjectOrFinishStackView.isHidden = false
        placeWireStackView.isHidden = true
        
        currentPlane = nil
        
        currentWireAnchorPoint = nil
        
        //we only want to worry about removing wire cursor when in draw mode
        loadedNodes.removeAll(where: { $0 is WireCursor })
        
        //remove wire cursor
        wireCursor?.removeFromParentNode()
        wireCursor = nil
    }
    
    @IBAction func userPressedFinish() {
        addObjectOrFinishStackView.isHidden = true
        //show screenshot stack
        captureStackView.isHidden = false
    }
    
    @IBAction func userPressedCapture() {
        //add wires
        quote.wires = confirmedWires.compactMap {
            guard $0.length != 0 else {
                return nil
            }
            
            return ACWire(wire: $0.wire, wireLength: $0.length)
        }
        
        //take a screenshot and move to quote view controller
        let capture = sceneView.snapshot()
        quote.screenshots.append(capture)
        
        //show quote view controller
        let vc = QuoteSummaryViewController()
        vc.quote = quote
        navigationController?.pushViewController(vc, animated: true)
    }
}
