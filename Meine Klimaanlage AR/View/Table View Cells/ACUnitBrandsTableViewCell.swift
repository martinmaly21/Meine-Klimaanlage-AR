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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func setUpCell(with brand: String) {
        let parsedBrand = brand.replacingOccurrences(of: " ", with: "_").lowercased()
        brandImageView.image = UIImage(named: "\(parsedBrand)_logo")
    }
}
