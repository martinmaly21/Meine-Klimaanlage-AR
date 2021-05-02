//
//  ACQuote.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-11.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import Foundation
import UIKit

struct ACQuote {
    var customerName: String?
    var employeeName: String?
    var appointmentDate: String?
    var locations: [ACLocation] = []
    
    var totalPrice: Float {
        var totalPrice: Float = 0
        
        locations.forEach {
            totalPrice += $0.price ?? 0
        }
        
        return totalPrice
    }
}
