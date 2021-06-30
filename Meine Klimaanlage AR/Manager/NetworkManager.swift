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
        case .daikin:
            return []
        case .mitsubishiMotors:
            return []
        case .panasonic:
            if unitType == .exterior {
                return []
            } else {
                //exterior
                let wandgeratLowEnergy = ACUnit(
                    displayName: "Wandgerät Baureihe TZ 2.5kW",
                    fileName: "Panasonic_Inside_Unit",
                    environmentType: .interior
                )
                let wandgeratHighEnergy = ACUnit(
                    displayName: "Wandgerät Baureihe TZ 3.5kW",
                    fileName: "Panasonic_Inside_Unit",
                    environmentType: .interior
                )
                
                return [wandgeratLowEnergy, wandgeratHighEnergy]
            }
        case .lg:
            if unitType == .exterior {
                return []
            } else {
                //exterior
                let wandgeratLowEnergy = ACUnit(
                    displayName: "LG Inside Unit 2.5kW",
                    fileName: "LG_Inside_Unit",
                    environmentType: .interior
                )
                let wandgeratHighEnergy = ACUnit(
                    displayName: "LG Inside Unit 3.5kW",
                    fileName: "LG_Inside_Unit",
                    environmentType: .interior
                )
                
                return [wandgeratLowEnergy, wandgeratHighEnergy]
            }
        case .samsung:
            return []
        }
    }
}
