//
//  WireSegmentAndPosition.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2021-04-21.
//  Copyright © 2021 Tim Kohmann. All rights reserved.
//

import UIKit


class WireSegmentAndPosition {
    let wireSegment: WireSegment
    let startPoint: CGPoint
    let endPoint: CGPoint
    
    init(
        wireSegment: WireSegment,
        startPoint: CGPoint,
        endPoint: CGPoint
    ) {
        self.wireSegment = wireSegment
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
}
