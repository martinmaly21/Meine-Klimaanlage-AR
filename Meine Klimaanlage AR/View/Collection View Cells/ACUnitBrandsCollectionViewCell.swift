//
//  ACUnitBrandsCollectionViewCell.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-10-24.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit

class ACUnitBrandsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var brandImageView: UIImageView!
    @IBOutlet weak var brandImageContainerView: UIView!
    @IBOutlet weak var brandLabel: UILabel!
    
    public var brand: ACBrand!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setUpCell(with brand: ACBrand) {
        self.brand = brand
        
        brandImageView.image = brand.getLogoImage()
        
        brandLabel.text = brand.rawValue
        
        containerView.layer.cornerRadius = 10
        containerView.layer.borderColor = Constants.Color.border.cgColor
        containerView.layer.borderWidth = 1
        
        containerView.layer.shadowColor = Constants.Color.border.cgColor
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        brandImageContainerView.layer.cornerRadius = 10
    }

}
