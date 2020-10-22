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
        #warning("need to change")
        static let quoteEmail = "martinmaly66@hotmail.com"
    }
    
    struct Color {
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
    }
}

