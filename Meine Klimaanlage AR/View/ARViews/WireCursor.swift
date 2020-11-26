//
//  WireCursor.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-08.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import Foundation
import ARKit

/**
 An `SCNNode` which is used to provide uses with visual cues about the status of ARKit world tracking.
 - Tag: FocusSquare
 */
class WireCursor: SCNNode {
    // MARK: - Types
    
    enum State: Equatable {
        case initializing
        case detecting(raycastResult: ARRaycastResult, camera: ARCamera?)
    }
    
    // MARK: - Configuration Properties
    
    var state: State = .initializing {
        didSet {
            guard state != oldValue else { return }
            
            switch state {
            case .initializing:
                displayAsBillboard()

            case let .detecting(raycastResult, camera):
                setPosition(with: raycastResult, camera)
            }
        }
    }
    
    /// Indicates if the square is currently changing its orientation when the camera is pointing downwards.
    private var isChangingOrientation = false
    
    /// Indicates if the camera is currently pointing towards the floor.
    private var isPointingDownwards = true
    
    /// The focus square's most recent positions.
    public var recentFocusSquarePositions: [SIMD3<Float>] = []
    
    /// A counter for managing orientation updates of the focus square.
    private var counterToNextOrientationUpdate: Int = 0
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        let cylinder = SCNCylinder(radius: 0.01, height: 0.001)
        self.geometry = cylinder
        let material = SCNMaterial()
        material.diffuse.contents = Constants.Color.primaryBlue
        self.geometry?.materials = [material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    // MARK: - Appearance
    
    /// Displays the focus square parallel to the camera plane.
    private func displayAsBillboard() {
        simdTransform = matrix_identity_float4x4
        eulerAngles.x = .pi / 2
        simdPosition = [0, 0, -0.8]
    }
    
    // - Tag: Set3DPosition
    func setPosition(with raycastResult: ARRaycastResult, _ camera: ARCamera?) {
        let position = raycastResult.worldTransform.translation
        recentFocusSquarePositions.append(position)
        updateTransform(for: raycastResult, camera: camera)
    }

    // MARK: Helper Methods
    
    // - Tag: Set3DOrientation
    func updateOrientation(basedOn raycastResult: ARRaycastResult) {
        self.simdOrientation = raycastResult.worldTransform.orientation
    }
    
    /// Update the transform of the focus square to be aligned with the camera.
    private func updateTransform(for raycastResult: ARRaycastResult, camera: ARCamera?) {
        // Average using several most recent positions.
        recentFocusSquarePositions = Array(recentFocusSquarePositions.suffix(10))
        
        // Move to average of recent positions to avoid jitter.
        let average = recentFocusSquarePositions.reduce([0, 0, 0], { $0 + $1 }) / Float(recentFocusSquarePositions.count)
        self.simdPosition = average
        self.simdScale = [1.0, 1.0, 1.0] * scaleBasedOnDistance(camera: camera)
        
        // Correct y rotation when camera is close to horizontal
        // to avoid jitter due to gimbal lock.
        guard let camera = camera else { return }
        let tilt = abs(camera.eulerAngles.x)
        let threshold: Float = .pi / 2 * 0.75
        
        if tilt > threshold {
            if !isChangingOrientation {
                let yaw = atan2f(camera.transform.columns.0.x, camera.transform.columns.1.x)
                
                isChangingOrientation = true
                SCNTransaction.begin()
                SCNTransaction.completionBlock = {
                    self.isChangingOrientation = false
                    self.isPointingDownwards = true
                }
                SCNTransaction.animationDuration = isPointingDownwards ? 0.0 : 0.5
                self.simdOrientation = simd_quatf(angle: yaw, axis: [0, 1, 0])
                SCNTransaction.commit()
            }
        } else {
            // Update orientation only twice per second to avoid jitter.
            if counterToNextOrientationUpdate == 30 || isPointingDownwards {
                counterToNextOrientationUpdate = 0
                isPointingDownwards = false
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                updateOrientation(basedOn: raycastResult)
                SCNTransaction.commit()
            }
            
            counterToNextOrientationUpdate += 1
        }
    }

    /**
     Reduce visual size change with distance by scaling up when close and down when far away.
     
     These adjustments result in a scale of 1.0x for a distance of 0.7 m or less
     (estimated distance when looking at a table), and a scale of 1.2x
     for a distance 1.5 m distance (estimated distance when looking at the floor).
     */
    private func scaleBasedOnDistance(camera: ARCamera?) -> Float {
        guard let camera = camera else { return 1.0 }

        let distanceFromCamera = simd_length(simdWorldPosition - camera.transform.translation)
        if distanceFromCamera < 0.7 {
            return distanceFromCamera / 0.7
        } else {
            return 0.25 * distanceFromCamera + 0.825
        }
    }
}
