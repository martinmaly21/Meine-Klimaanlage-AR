//
//  ACUnitDetailPageTableHeaderView.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-14.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit

protocol ACUnitDetailPageTableHeaderViewDelegate: class {
    func userChangedACUnitEnvironmentType(with newType: ACUnitEnvironmentType)
}

class ACUnitDetailPageTableHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var ACUnitHeaderImageView: UIImageView!
    @IBOutlet weak var ACUnitHeaderSegmentedControl: UISegmentedControl!
    public weak var delegate: ACUnitDetailPageTableHeaderViewDelegate?
    
    @IBAction func segmentedControllerDidChange(_ sender: UISegmentedControl) {
        let newACUnitEnvironmentType: ACUnitEnvironmentType = sender.selectedSegmentIndex == 0 ? .interior : .exterior
        delegate?.userChangedACUnitEnvironmentType(with: newACUnitEnvironmentType)
    }
}
