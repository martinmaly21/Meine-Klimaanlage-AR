//
//  Wire.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-11.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import Foundation

enum WireType {
    case kundenname
    case verkäufer
    case kondensatleitung
}

enum WireLocation {
    case insideWall
    case outsideWall
}

struct Wire {
    var wireType: WireType
    var wireLocation: WireLocation
    var wireLength: Double = 0
}
