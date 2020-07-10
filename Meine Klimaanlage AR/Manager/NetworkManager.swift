//
//  NetworkManager.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-07.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import Foundation


class NetworkManager {
    public static var shared = NetworkManager()
    
    public static func getUnits(for brand: ACBrand, with unitType: ACUnitEnvironmentType) -> [ACUnit] {
        switch brand {
        case .panasonic:
            if unitType == .exterior {
                return [ACUnit(displayName: "Model 1", fileName: "Panasonic")]
            } else {
                //exterior
                let firstUnit = ACUnit(displayName: "Wandgerät Baureihe TZ", fileName: "Panasonic")
                //this is the one i have the model for rn
                let secondUnit = ACUnit(displayName: "ETHEREA Wandgerät Baureihe Z", fileName: "Panasonic")
                let thirdUnit = ACUnit(displayName: "Wandgerät Baureihe TKEA Professional", fileName: "Panasonic")
                return [firstUnit, secondUnit, thirdUnit]
            }
        default:
            return []
        }
    }
}
