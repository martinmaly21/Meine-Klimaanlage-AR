//
//  QuoteLocationTableViewCell.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2021-05-01.
//  Copyright © 2021 Tim Kohmann. All rights reserved.
//

import UIKit

class QuoteLocationTableViewCell: UITableViewCell {
    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var acUnitLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var wiresLabel: UILabel!
    
    public var acLocation: ACLocation?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    public func setUpCell(with acLocation: ACLocation?) {
        self.acLocation = acLocation
        
        for (index, screenshot) in (acLocation?.screenshots ?? []).enumerated() {
            imageViews[index].image = screenshot
        }
        
        locationLabel.text = acLocation?.name
        acUnitLabel.text = acLocation?.acUnit.displayName
        
        if let price = acLocation?.price {
            priceLabel.text = "\(price) Euro"
        }
        
        wiresLabel.text = "Wires: \(acLocation?.wires.count ?? 0)"
    }
}
