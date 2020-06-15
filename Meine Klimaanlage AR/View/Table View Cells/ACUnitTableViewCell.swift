//
//  ACUnitTableViewCell.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-07.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit

class ACUnitTableViewCell: UITableViewCell {
    @IBOutlet weak var ACUnitBrandLabel: UILabel!
    
    public var unit: ACUnit!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = .disclosureIndicator
    }

    public func setUpCell(with unit: ACUnit) {
        self.unit = unit
        
        ACUnitBrandLabel.text = unit.name
    }
}
