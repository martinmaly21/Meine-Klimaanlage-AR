//
//  WireCursor.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-08.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import Foundation
import ARKit

class WireCursor: SCNNode {
    
    override init() {
        super.init()
        let dimension: CGFloat = 0.02
        let circle = SCNPlane(width: dimension, height: dimension)
        circle.cornerRadius = dimension / 2
        geometry = circle
        
        geometry?.firstMaterial?.isDoubleSided = true
        geometry?.firstMaterial?.diffuse.contents = Constants.Color.primaryBlue
        
        categoryBitMask = HitTestType.wireCursor.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
}
