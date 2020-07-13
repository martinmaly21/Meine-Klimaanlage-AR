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
    var price: String?
    
    var wires: [Wire]  = []
    var units: [ACUnit]
    var screenshots: [UIImage] = []
    
    var wifi = false
    var elZul = false
    var uv = false
    var dachdecker = false
    var dachdruchfuhrung = false
    var kondensatpumpe = false
    
    var notes: String?
}
