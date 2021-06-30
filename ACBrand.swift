//
//  ACBrand.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-14.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import Foundation
import UIKit

enum ACBrand: String {
    case daikin = "Daikin"
    case mitsubishiMotors = "Mitsubishi Motors"
    case panasonic = "Panasonic"
    case lg = "LG"
    case samsung = "Samsung"
    
    func getLogoImage() -> UIImage? {
        let parsedBrand = rawValue.replacingOccurrences(of: " ", with: "_").lowercased()
        return UIImage(named: "\(parsedBrand)_logo")
    }
}
