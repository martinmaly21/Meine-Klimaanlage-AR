//
//  QuoteLocationTableViewCell.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2021-05-01.
//  Copyright © 2021 Tim Kohmann. All rights reserved.
//

import UIKit

class QuoteLocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var locationLabel: UILabel!
    
    public var acLocation: ACLocation?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    public func setUpCell(with locationName: String?) {
        locationLabel.text = locationName
    }
}
