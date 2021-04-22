//
//  ARWire.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2021-04-21.
//  Copyright © 2021 Tim Kohmann. All rights reserved.
//

import Foundation


class ARWire {
    var length: Float {
        var totalLength: Float = 0
        
        segments.forEach {
            totalLength += $0.length
        }
        
        return totalLength
    }
    let wire: ACWire
    var segments: [WireSegment] = []
    
    init(wire: ACWire) {
        self.wire = wire
    }
}
