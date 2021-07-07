//
//  UnitManager.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-07.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import Foundation


class UnitManager {
    public static var shared = UnitManager()
    
    public static func getUnits(for brand: ACBrand, with unitType: ACUnitEnvironmentType) -> [ACUnit] {
        switch brand {
        case .daikin:
            if unitType == .exterior {
                return []
            } else {
                //exterior
                let daikinLowEnergy = ACUnit(
                    displayName: "Daikin Inside Unit 2.5kW",
                    fileName: "Daikin_Inside_Unit",
                    environmentType: .interior
                )
                let daikinHighEnergy = ACUnit(
                    displayName: "Daikin Inside Unit 3.5kW",
                    fileName: "Daikin_Inside_Unit",
                    environmentType: .interior
                )
                
                return [daikinLowEnergy, daikinHighEnergy]
            }
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
            if unitType == .exterior {
                return []
            } else {
                //exterior
                let samsungLowEnergy = ACUnit(
                    displayName: "Samsung Inside Unit 2.5kW",
                    fileName: "Samsung_Inside_Unit",
                    environmentType: .interior
                )
                let samsungHighEnergy = ACUnit(
                    displayName: "Samsung Inside Unit 3.5kW",
                    fileName: "Samsung_Inside_Unit",
                    environmentType: .interior
                )
                
                return [samsungLowEnergy, samsungHighEnergy]
            }
        }
    }
}
