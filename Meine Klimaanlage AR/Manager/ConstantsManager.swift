//
//  ConstantsManager.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-12.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    enum Quote {
        #warning("need to change email")
        static let quoteEmail = "timkohmann25@gmail.com"
    }
    
    enum Color {
        public static let border = UIColor(named: "Border")!
        public static let highlightBlue = UIColor(named: "HighlightBlue")!
        public static let primaryBlue = UIColor(named: "PrimaryBlue")!
        public static let primaryGreyBackground = UIColor(named: "PrimaryGreyBackground")!
        public static let primaryTextDark = UIColor(named: "PrimaryTextDark")!
        public static let primaryTextLight = UIColor(named: "PrimaryTextLight")!
        public static let primaryWhiteBackground = UIColor(named: "PrimaryWhiteBackground")!
        public static let secondaryTextDark = UIColor(named: "SecondaryTextDark")!
        public static let tertiaryTextDark = UIColor(named: "TertiaryTextDark")!
        public static let shadow = UIColor(named: "Shadow")!
        public static let primaryRed = UIColor(named: "PrimaryRed")!
        public static let veryLightGrey = UIColor(named: "VeryLightGrey")!
        public static let highlightGrey = UIColor(named: "HighlightGrey")!
    }
}

