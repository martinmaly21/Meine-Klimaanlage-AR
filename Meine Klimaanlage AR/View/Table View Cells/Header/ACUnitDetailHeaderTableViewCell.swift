//
//  ACUnitDetailHeaderTableViewCell.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-10-24.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit

protocol ACUnitDetailPageTableHeaderViewDelegate: class {
    func userChangedACUnitEnvironmentType(with newType: ACUnitEnvironmentType)
}

class ACUnitDetailHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var ACUnitHeaderImageView: UIImageView!
    @IBOutlet weak var ACUnitHeaderSegmentedControl: UISegmentedControl!
    public weak var delegate: ACUnitDetailPageTableHeaderViewDelegate?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
    }
    
    public func setUpHeaderView(with brand: ACBrand) {
        ACUnitHeaderImageView.image = brand.getLogoImage()
    }
    
    @IBAction func segmentedControllerDidChange(_ sender: UISegmentedControl) {
        let newACUnitEnvironmentType: ACUnitEnvironmentType = sender.selectedSegmentIndex == 0 ? .interior : .exterior
        delegate?.userChangedACUnitEnvironmentType(with: newACUnitEnvironmentType)
    }
    
}
