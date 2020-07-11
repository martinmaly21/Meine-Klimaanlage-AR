//
//  ACQuote.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-11.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import Foundation

struct ACQuote {
    let customerName: String
    let employeeName: String
    let appointmentDate: Date //maybe even a string
    
    var rohrleitungslangeLength: Double = 0
    var kabelkanalLength: Double =  0
    var kondensatleitungLength: Double = 0
    
    
    var unitNames: [String]
    
    var kondensatpumpe = false
    var dachdecker = false
    var dachdruchfuhrung = false
    
    var price: Double
    
    var notes: String
}
