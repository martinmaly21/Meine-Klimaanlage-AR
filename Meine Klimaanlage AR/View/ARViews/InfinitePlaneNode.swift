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
    
    private var skScene: SKScene = {
        let scene = SKScene(
            size: .init(
                width: Constants.AR.assumedInfinitePlaneDimension * 100,
                height: Constants.AR.assumedInfinitePlaneDimension * 100
            )
        )
        scene.backgroundColor = .red
        
        return scene
    }()
    
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
        
        plane.firstMaterial?.diffuse.contents = skScene
        plane.firstMaterial?.isDoubleSided = true
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
