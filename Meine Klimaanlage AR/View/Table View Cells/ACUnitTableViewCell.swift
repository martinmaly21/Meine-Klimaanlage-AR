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
    @IBOutlet weak var containerView: UIView!
    
    public var unit: ACUnit!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        
        setUpUI()
    }
    
    private func setUpUI() {
        containerView.layer.cornerRadius = 10
        containerView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        containerView.layer.borderWidth = 1
        
        containerView.layer.shadowColor = Constants.Color.border.cgColor
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        containerView.layer.shadowOpacity = 0.3
    }

    public func setUpCell(with unit: ACUnit) {
        self.unit = unit
        
        ACUnitBrandLabel.text = unit.displayName
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            highlightCell()
        } else {
            unHighlightCell()
        }
    }
    
    public func highlightCell() {
        removeShadow()
        dimView()
    }
    
    public func unHighlightCell() {
        addShadow()
        unDimView()
    }
    
    private func addShadow() {
        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.fromValue = layer.shadowOpacity
        animation.toValue = 0.3
        animation.duration = 0.05
        containerView.layer.add(animation, forKey: animation.keyPath)
        containerView.layer.shadowOpacity = 0.3
    }
    
    private func removeShadow() {
        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.fromValue = layer.shadowOpacity
        animation.toValue = 0.0
        animation.duration = 0.05
        containerView.layer.add(animation, forKey: animation.keyPath)
        containerView.layer.shadowOpacity = 0.0
    }
    
    private func dimView() {
        UIView.animate(
            withDuration: 0.05) {
            self.containerView.backgroundColor = Constants.Color.highlightGrey
        }
    }
    
    private func unDimView() {
        UIView.animate(
            withDuration: 0.05) {
            self.containerView.backgroundColor = UIColor.white
        }
    }
}
