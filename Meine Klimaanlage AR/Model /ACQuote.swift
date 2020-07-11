//
//  ACQuote.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-11.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import Foundation

struct ACQuote {
    var customerName: String?
    var employeeName: String?
    var appointmentDate: String?
    
    var rohrleitungslangeLength: Double = 0
    var kabelkanalLength: Double =  0
    var kondensatleitungLength: Double = 0
    
    
    var units: [ACUnit]
    
    var kondensatpumpe = false
    var dachdecker = false
    var dachdruchfuhrung = false
    
    var price: Double?
    
    var notes: String?
}
