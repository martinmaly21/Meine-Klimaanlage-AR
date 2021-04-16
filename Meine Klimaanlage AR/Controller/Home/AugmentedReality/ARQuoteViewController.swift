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
            let pointOfViewEulerAngle = pointOfView.eulerAngles
            
            acUnit.load()
            
            acUnit.transform = pointOfView.transform
            acUnit.eulerAngles = SCNVector3(0, pointOfViewEulerAngle.y, 0)
            
            let dimension: CGFloat = 2
            let plane = SCNPlane(width: dimension, height: dimension)
            plane.firstMaterial?.diffuse.contents = UIImage(named: "grid")
            plane.cornerRadius = dimension / 2
            plane.firstMaterial?.isDoubleSided = true
            plane.firstMaterial?.blendMode = .max
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.transform = pointOfView.transform
            planeNode.eulerAngles = SCNVector3(0, pointOfViewEulerAngle.y, 0)
            
            sceneView.scene.rootNode.addChildNode(acUnit)
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
