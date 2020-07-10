//
//  ACUnitBrandsTableViewCell.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-07.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit

class ACUnitBrandsTableViewCell: UITableViewCell {
    @IBOutlet weak var brandImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    public var brand: ACBrand!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    public func setUpCell(with brand: ACBrand) {
        self.brand = brand

        brandImageView.image = brand.getLogoImage()
        
        containerView.layer.cornerRadius = 10
        containerView.layer.borderColor = UIColor(named: "Border")?.cgColor
        containerView.layer.borderWidth = 1
        
    }
}
