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
                return [ACUnit(name: "Model 1")]
            } else {
                //exterior
                let firstUnit = ACUnit(name: "Wandgerät Baureihe TZ")
                //this is the one i have the model for rn
                let secondUnit = ACUnit(name: "ETHEREA Wandgerät Baureihe Z")
                let thirdUnit = ACUnit(name: "Wandgerät Baureihe TKEA Professional")
                return [firstUnit, secondUnit, thirdUnit]
            }
        default:
            return []
        }
    }
}
