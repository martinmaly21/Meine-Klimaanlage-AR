//
//  Wire.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-11.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import Foundation

enum WireType {
    case rohrleitungslänge
    case kabelkanal
    case kondensatleitung
}

enum WireLocation {
    case insideWall
    case outsideWall
}

struct ACWire {
    var wireDisplayName: String
    var wireType: WireType
    var wireLocation: WireLocation
    var wireLength: Float = 0
    
    init(wireType: WireType, wireLocation: WireLocation) {
        self.wireType = wireType
        self.wireLocation = wireLocation
        
        switch wireType {
        case .rohrleitungslänge:
            wireDisplayName = "Rohrleitungslänge"
        case .kabelkanal:
            wireDisplayName = "Kabelkanal"
        case .kondensatleitung:
            wireDisplayName = "Kondensatleitung"
        }
    }
}