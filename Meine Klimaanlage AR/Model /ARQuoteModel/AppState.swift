//
//  AppState.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-11-22.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import Foundation

enum AppState: Int16 {
    case noUnitPlaced
    
    case addingUnit
    case addedUnit
    
    case addingWire
    case addedWire
    
    case captureScreenshot
}
