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
    public var brand: ACBrand!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    public func setUpCell(with brand: ACBrand) {
        self.brand = brand
        
        let parsedBrand = brand.rawValue.replacingOccurrences(of: " ", with: "_").lowercased()
        brandImageView.image = UIImage(named: "\(parsedBrand)_logo")
    }
}
