//
//  HitTestType.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2021-04-16.
//  Copyright © 2021 Tim Kohmann. All rights reserved.
//

import Foundation

enum HitTestType: Int {
    case acUnit = 0b0001
    case plane = 0b0010
    case wireCursor = 0b0011
    case wire = 0b00100
}
