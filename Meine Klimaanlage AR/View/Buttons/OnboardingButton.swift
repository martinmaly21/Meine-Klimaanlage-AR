//
//  OnboardingButton.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-10-21.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit

class OnboardingButton: UIButton {
    
    override var isHighlighted: Bool {
        didSet {
            layer.shadowOpacity = isHighlighted ? 0 : 1.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp() {
        layer.shadowColor = Constants.Color.shadow.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 0.0
        layer.masksToBounds = false
        layer.cornerRadius = 8.0
    }
}
