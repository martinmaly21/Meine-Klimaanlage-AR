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

struct Wire {
    var wireType: WireType
    var wireLocation: WireLocation
    var wireLength: Float = 0
}
