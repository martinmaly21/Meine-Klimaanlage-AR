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
    
    private var currentACUnitNode: SCNNode?
    
    //store previous coordinates from hittest to compare with current ones
    private var previousPanCoordinate: CGPoint?
    private var trackedObject: SCNNode?
    
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
        
        //add gesture recognizers
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(userPannedScreen(_:)))
        sceneView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func userPannedScreen(_ panGesture: UIPanGestureRecognizer){
        let location = panGesture.location(in: sceneView)
        let acUnitBitMask = HitTestType.acUnit.rawValue
        
        switch panGesture.state {
        case .began:
            if let hitTestResult = sceneView.hitTest(
                location,
                options: [SCNHitTestOption.categoryBitMask : acUnitBitMask]
            ).first {
                //user is panning AC unit
                trackedObject = currentACUnitNode
                
                previousPanCoordinate = CGPoint(
                    x: Double(hitTestResult.worldCoordinates.x),
                    y: Double(hitTestResult.worldCoordinates.y)
                )
            }
        case .changed:
            guard let trackedObject = trackedObject,
                  let previousPanCoordinate = previousPanCoordinate else { return }
            // when you start to pan in screen with your finger
            // hittest gives new coordinates of touched location in sceneView
            // coord-pcoord gives distance to move or distance paned in sceneview
            if let hitTestResult = sceneView.hitTest(
                location,
                options: [SCNHitTestOption.categoryBitMask : acUnitBitMask]
            ).first {
                let coordx = hitTestResult.worldCoordinates.x
                let coordy = hitTestResult.worldCoordinates.y
                
                let action = SCNAction
                    .moveBy(
                        x: CGFloat(coordx - Float(previousPanCoordinate.x)),
                        y: CGFloat(coordy - Float(previousPanCoordinate.y)),
                        z: 0,
                        duration: 0.1
                    )
                
                trackedObject.runAction(action)
                
                self.previousPanCoordinate = CGPoint(
                    x: Double(coordx),
                    y: Double(coordy)
                )
            }
            
            panGesture.setTranslation(CGPoint.zero, in: sceneView)
        case .ended:
            trackedObject = nil
            previousPanCoordinate = nil
        default:
            break
        }
        
    }
    
    private func removeGestureRecognizersFromView() {
        //call when user has finished placing AC unit
        for gestureRecognizer in sceneView.gestureRecognizers ?? [] {
            sceneView.removeGestureRecognizer(gestureRecognizer)
        }
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
    
    private func addVerticalAnchorCoachingView() {
        //show coaching thing
        let verticalAnchorCoachingView = VerticalAnchorCoachingView()
        verticalAnchorCoachingView.delegate = self
        
        verticalAnchorCoachingView.translatesAutoresizingMaskIntoConstraints = false
        
        sceneView.addSubview(verticalAnchorCoachingView)
        
        verticalAnchorCoachingView.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor, constant: 10).isActive = true
        verticalAnchorCoachingView.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor, constant: -10).isActive = true
        verticalAnchorCoachingView.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 10).isActive = true
        verticalAnchorCoachingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
    }
    
    private func addACUnit() {
        if let filePath = Bundle.main.path(forResource: currentACUnit.fileName, ofType: "scn", inDirectory: "ACUnits.scnassets") {
            let referenceURL = URL(fileURLWithPath: filePath)
            
            guard let acUnit = SCNReferenceNode(url: referenceURL),
                  let pointOfView = sceneView.pointOfView else {
                fatalError("Could not get currentFrame or pointOfView")
            }
            
            
            //set bit mask so it can be located in hit test
            acUnit.categoryBitMask = HitTestType.acUnit.rawValue
            
            let pointOfViewEulerAngle = pointOfView.eulerAngles
            
            acUnit.load()
            
            currentACUnitNode = acUnit
            
            let dimension: CGFloat = 2
            let plane = SCNPlane(width: dimension, height: dimension)
            plane.firstMaterial?.diffuse.contents = UIImage(named: "grid")
            plane.cornerRadius = dimension / 2
            plane.firstMaterial?.isDoubleSided = true
            plane.firstMaterial?.blendMode = .max
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.transform = pointOfView.transform
            planeNode.eulerAngles = SCNVector3(0, pointOfViewEulerAngle.y, 0)
            planeNode.categoryBitMask = HitTestType.plane.rawValue
            
            
            planeNode.addChildNode(acUnit)
            
            sceneView.scene.rootNode.addChildNode(planeNode)
            
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
}
