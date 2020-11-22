//
//  AppState.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-11-22.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import Foundation

enum AppState: Int16 {
    case lookingForSurface  // Just starting out; no surfaces detected yet
    case pointToSurface     // Surfaces detected, but device is not pointing to any of them
    case readyToFurnish     // Surfaces detected *and* device is pointing to at least one
}
