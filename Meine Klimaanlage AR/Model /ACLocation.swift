//
//  ACLocation.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2021-05-01.
//  Copyright © 2021 Tim Kohmann. All rights reserved.
//

import UIKit

//Make this a class so that we don't have to pass in it's parent quote when modifying it
class ACLocation: Identifiable {
    var name: String?
    
    var price: Float = 0
    
    var acUnit: ACUnit
    var wires: [ACWire]  = []
    
    var screenshots: [UIImage] = []
    
    var wifi = false
    var elZul = false
    var uv = false
    var dachdecker = false
    var dachdruchführung = false
    var kondensatpumpe = false
    
    var notes: String?
    
    init(acUnit: ACUnit) {
        self.acUnit = acUnit
    }

    func isComplete() -> Bool {
        guard let name = name, !name.isEmpty,
              price != 0,
              !screenshots.isEmpty else {
            return false
        }
        
        return true
    }
}
