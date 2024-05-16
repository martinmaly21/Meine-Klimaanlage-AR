//
//  InfinitePlaneNode.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2021-04-18.
//  Copyright © 2021 Tim Kohmann. All rights reserved.
//

import SceneKit
import SpriteKit


class InfinitePlaneNode: SCNNode {
    
    override init() {
        super.init()
        //assume 100x100 is infinite plane
        let plane = SCNPlane(
            width: Constants.AR.assumedInfinitePlaneDimension,
            height: Constants.AR.assumedInfinitePlaneDimension
        )
        
        geometry = plane
        
        //set bit mask so we can hit test for this node
        categoryBitMask = HitTestType.plane.rawValue
        
        plane.firstMaterial?.diffuse.contents = UIColor.clear
        plane.firstMaterial?.isDoubleSided = true
        
        //add shadow plane
        let shadowPlane = SCNPlane(
            width: Constants.AR.assumedInfinitePlaneDimension,
            height: Constants.AR.assumedInfinitePlaneDimension
        )
        let worldGroundPlane = SCNNode()
        let worldGroundMaterial = SCNMaterial()
        
        worldGroundMaterial.lightingModel = .constant
        worldGroundMaterial.writesToDepthBuffer = true
        worldGroundMaterial.colorBufferWriteMask = []
        worldGroundMaterial.isDoubleSided = true
        worldGroundMaterial.diffuse.contents = UIColor.white.withAlphaComponent(1)  // Slightly visible to see the shadows
        shadowPlane.materials = [worldGroundMaterial]
        worldGroundPlane.geometry = shadowPlane
        addChildNode(worldGroundPlane)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
